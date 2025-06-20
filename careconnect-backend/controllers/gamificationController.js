const pool = require('../db');

exports.awardXP = async (req, res) => {
  const { userId, xpEarned } = req.body;

  try {
    const existing = await pool.query('SELECT xp, level FROM xp_progress WHERE user_id = $1', [userId]);
    let xp = xpEarned;
    let level = 1;

    if (existing.rows.length > 0) {
      xp += existing.rows[0].xp;
      level = existing.rows[0].level;
      if (xp >= level * 50) level += 1;

      await pool.query('UPDATE xp_progress SET xp = $1, level = $2, updated_at = NOW() WHERE user_id = $3', [xp, level, userId]);
    } else {
      await pool.query('INSERT INTO xp_progress (user_id, xp, level) VALUES ($1, $2, $3)', [userId, xp, level]);
    }

    res.status(200).json({ message: 'XP awarded', xp, level });
  } catch (err) {
    console.error('XP award error:', err);
    res.status(500).json({ message: 'Server error' });
  }
};

exports.getXPProgress = async (req, res) => {
  const { userId } = req.params;

  try {
    const result = await pool.query('SELECT xp, level FROM xp_progress WHERE user_id = $1', [userId]);
    res.status(200).json(result.rows[0] || { xp: 0, level: 1 });
  } catch (err) {
    res.status(500).json({ message: 'Error fetching progress' });
  }
};

exports.getAchievements = async (req, res) => {
  const { userId } = req.params;

  try {
    const result = await pool.query(
      `SELECT a.id, a.title, a.description, a.badge_icon, ua.awarded_at
       FROM achievements a
       JOIN user_achievements ua ON a.id = ua.achievement_id
       WHERE ua.user_id = $1`,
      [userId]
    );

    res.status(200).json(result.rows);
  } catch (error) {
    console.error("Error fetching achievements:", error);
    res.status(500).json({ message: 'Error fetching achievements' });
  }
};



exports.getAllAchievements = async (req, res) => {
  const { userId } = req.params;

  try {
    const all = await pool.query(`
      SELECT a.id, a.title, a.description, a.badge_icon,
             CASE WHEN ua.user_id IS NOT NULL THEN true ELSE false END as unlocked,
             ua.awarded_at
      FROM achievements a
      LEFT JOIN user_achievements ua ON a.id = ua.achievement_id AND ua.user_id = $1
      ORDER BY a.id;
    `, [userId]);

    res.status(200).json(all.rows);
  } catch (err) {
    console.error('Error fetching all achievements:', err);
    res.status(500).json({ message: 'Error fetching all achievements' });
  }
};
