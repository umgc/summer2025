const fs = require('fs');
const path = require('path');
const pool = require('../db');
const bcrypt = require('bcrypt');
const saltRounds = 10;
const crypto = require('crypto');
const nodemailer = require('nodemailer');

exports.registerUser = async (req, res) => {
  const { name, email, password, role = 'patient' } = req.body;

  if (!name || !email || !password) {
    return res.status(400).json({ message: 'Name, email, and password are required.' });
  }

  try {
    // Check if email already exists
    const existingUser = await pool.query(
      'SELECT id FROM users WHERE email = $1 AND role = $2',
      [email, role]
    );

    if (existingUser.rows.length > 0) {
      return res.status(409).json({ message: `Email already registered with role ${role}.` });
    }

    const hashedPassword = await bcrypt.hash(password, saltRounds);
    const token = crypto.randomBytes(32).toString('hex');

    const result = await pool.query(
      `INSERT INTO users (name, email, password, created_at, is_verified, verification_token, role)
       VALUES ($1, $2, $3, NOW(), false, $4, $5)
       RETURNING id, name, email, role`,
      [name, email, hashedPassword, token, role]
    );

    const userId = result.rows[0].id;

    // Initialize XP and "First Step" achievement
    try {
      await pool.query(
        'INSERT INTO xp_progress (user_id, xp, level) VALUES ($1, $2, $3)',
        [userId, 10, 1]
      );

      let achievement = await pool.query(
        'SELECT id FROM achievements WHERE title = $1',
        ['First Step']
      );

      let achievementId;
      if (achievement.rows.length === 0) {
        const inserted = await pool.query(
          `INSERT INTO achievements (title, description, xp_required, badge_icon)
           VALUES ($1, $2, $3, $4) RETURNING id`,
          ['First Step', 'Welcome to CareConnect!', 10, '🎉']
        );
        achievementId = inserted.rows[0].id;
      } else {
        achievementId = achievement.rows[0].id;
      }

      await pool.query(
        'INSERT INTO user_achievements (user_id, achievement_id) VALUES ($1, $2)',
        [userId, achievementId]
      );
    } catch (err) {
      console.error("Gamification setup error during registration:", err);
    }

    // Send verification email
    const transporter = nodemailer.createTransport({
      service: 'Gmail',
      auth: {
        user: 'bomplar@gmail.com',
        pass: 'rxusxjpjoqqeyogl',
      },
    });

    const verifyUrl = `http://localhost:3000/api/auth/verify/${token}`;
    const mailOptions = {
      from: 'your_email@gmail.com',
      to: email,
      subject: 'Verify Your Email - CareConnect',
      html: `<p>Welcome to CareConnect!</p><p>Click <a href="${verifyUrl}">here</a> to verify your email address.</p>`,
    };

    await transporter.sendMail(mailOptions);

    res.status(201).json({
      message: 'User registered! Please check your email to verify your account.',
      user: result.rows[0],
    });

  } catch (error) {
    console.error("Registration error:", error);
    res.status(500).json({ message: "Server error during registration." });
  }
};

exports.loginUser = async (req, res) => {
  const { email, password, role } = req.body;

  if (!email || !password) {
    return res.status(400).json({ message: "Email and password are required." });
  }

  try {
    const result = await pool.query(
      'SELECT * FROM users WHERE email = $1 AND role = $2',
      [email, role]
    );
    const user = result.rows[0];

    if (!user) return res.status(401).json({ message: "Invalid email or password." });
    if (!user.is_verified) {
      return res.status(403).json({ message: "Please verify your email before logging in." });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) return res.status(401).json({ message: "Invalid email or password." });

    req.session.userId = user.id;
    const isFirstLogin = !user.last_login;

    await pool.query('UPDATE users SET last_login = NOW() WHERE id = $1', [user.id]);

    if (isFirstLogin) {
      // Grant XP (initialize if missing)
      const xpExists = await pool.query('SELECT 1 FROM xp_progress WHERE user_id = $1', [user.id]);
      if (xpExists.rowCount === 0) {
        await pool.query('INSERT INTO xp_progress (user_id, xp, level) VALUES ($1, $2, $3)', [user.id, 10, 1]);
      } else {
        await pool.query('UPDATE xp_progress SET xp = xp + 10 WHERE user_id = $1', [user.id]);
      }

      // Grant "First Login" achievement
      let ach = await pool.query(
        'SELECT id FROM achievements WHERE title = $1',
        ['First Login']
      );

      let achievementId;
      if (ach.rows.length === 0) {
        const inserted = await pool.query(
          `INSERT INTO achievements (title, description, xp_required, badge_icon)
           VALUES ($1, $2, $3, $4) RETURNING id`,
          ['First Login', 'Logged in for the first time!', 10, '🔓']
        );
        achievementId = inserted.rows[0].id;
      } else {
        achievementId = ach.rows[0].id;
      }

      const existing = await pool.query(
        'SELECT 1 FROM user_achievements WHERE user_id = $1 AND achievement_id = $2',
        [user.id, achievementId]
      );

      if (existing.rowCount === 0) {
        await pool.query(
          'INSERT INTO user_achievements (user_id, achievement_id) VALUES ($1, $2)',
          [user.id, achievementId]
        );
      }
    }

    return res.status(200).json({
      message: "Login successful",
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
        profileImageUrl: user.profile_image_url || null, // ✅ Include profile picture
      }
    });
  } catch (err) {
    console.error("Login error:", err);
    return res.status(500).json({ message: "Server error during login." });
  }
};

exports.getProfile = (req, res) => {
  if (!req.session.userId) {
    return res.status(401).json({ message: "Not logged in" });
  }

  res.status(200).json({
    message: "Session valid",
    userId: req.session.userId,
  });
};

exports.logoutUser = (req, res) => {
  req.session.destroy((err) => {
    if (err) {
      console.error("Logout error:", err);
      return res.status(500).json({ message: "Logout failed" });
    }

    res.clearCookie('connect.sid');
    res.status(200).json({ message: "Logout successful" });
  });
};

exports.verifyEmail = async (req, res) => {
  const { token } = req.params;

  try {
    const result = await pool.query(
      'UPDATE users SET is_verified = true, verification_token = NULL WHERE verification_token = $1 RETURNING id',
      [token]
    );

    if (result.rowCount === 0) {
      return res.status(400).json({ message: 'Invalid or expired token.' });
    }

    res.status(200).json({ message: 'Email verified successfully!' });
  } catch (error) {
    console.error('Verification error:', error);
    res.status(500).json({ message: 'Server error during verification.' });
  }
};

// POST /api/auth/avatar/:userId
exports.uploadAvatar = async (req, res) => {
  const { userId } = req.params;
  const avatarFile = req.file;

  if (!avatarFile) {
    return res.status(400).json({ error: 'No file uploaded' });
  }

  try {
    const newPath = `/uploads/${avatarFile.filename}`;

    // Fetch old profile_image_url
    const result = await pool.query('SELECT profile_image_url FROM users WHERE id = $1', [userId]);
    const oldPath = result.rows[0]?.profile_image_url;

    // Delete old file if it exists
    if (oldPath) {
      const fullPath = path.join(__dirname, '..', oldPath);
      if (fs.existsSync(fullPath)) {
        fs.unlinkSync(fullPath);
        console.log(`Deleted old avatar: ${oldPath}`);
      }
    }

    // Update database with new avatar path
    await pool.query(
      'UPDATE users SET profile_image_url = $1 WHERE id = $2',
      [newPath, userId]
    );

    res.status(200).json({ message: 'Avatar uploaded', imageUrl: newPath });
  } catch (err) {
    console.error('Error uploading avatar:', err);
    res.status(500).json({ error: 'Server error' });
  }
};
