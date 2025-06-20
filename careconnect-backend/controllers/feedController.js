const pool = require('../db');
const path = require('path');

// GET /api/feed/:userId
exports.getUserFeed = async (req, res) => {
  const { userId } = req.params;

  try {
    const friendsQuery = `
      SELECT friend_id AS friend FROM friendships WHERE user_id = $1 AND status = 'accepted'
      UNION
      SELECT user_id AS friend FROM friendships WHERE friend_id = $1 AND status = 'accepted'
    `;
    const friendsResult = await pool.query(friendsQuery, [userId]);
    const friendIds = friendsResult.rows.map(row => row.friend);
    const idsToQuery = [...friendIds, parseInt(userId)];

    if (idsToQuery.length === 0) {
      return res.json({ feed: [] });
    }

    const feedQuery = `
      SELECT p.id, p.content, p.created_at, p.image_url,
             u.name AS username, u.profile_image_url,
             COUNT(c.id) AS comment_count
      FROM posts p
      JOIN users u ON p.user_id = u.id
      LEFT JOIN comments c ON c.post_id = p.id
      WHERE p.user_id = ANY($1::int[])
      GROUP BY p.id, p.content, p.created_at, p.image_url, u.name, u.profile_image_url
      ORDER BY p.created_at DESC
      LIMIT 50
    `;
    const feedResult = await pool.query(feedQuery, [idsToQuery]);

    const formattedFeed = feedResult.rows.map(post => ({
      id: post.id,
      username: post.username,
      profileImageUrl: post.profile_image_url || null,
      content: post.content,
      imageUrl: post.image_url,
      timestamp: new Date(post.created_at).toLocaleString('en-US', {
        hour: 'numeric',
        minute: '2-digit',
        hour12: true,
        month: 'short',
        day: 'numeric',
      }),
      commentCount: post.comment_count,
    }));

    res.json({ feed: formattedFeed });
  } catch (err) {
    console.error('Error fetching feed:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
};

// POST /api/feed
exports.createPost = async (req, res) => {
  const { userId, content } = req.body;
  const imageFile = req.file;

  if (!userId || !content) {
    return res.status(400).json({ error: 'userId and content are required' });
  }

  try {
    const imageUrl = imageFile ? `/uploads/${imageFile.filename}` : null;

    const query = `
      INSERT INTO posts (user_id, content, image_url, created_at)
      VALUES ($1, $2, $3, NOW())
      RETURNING id, user_id, content, image_url, created_at
    `;
    const result = await pool.query(query, [userId, content, imageUrl]);

    res.status(201).json({
      message: 'Post created successfully',
      post: result.rows[0]
    });
  } catch (err) {
    console.error('Error creating post:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
};

// GET /api/feed/:postId/comments
exports.getComments = async (req, res) => {
  const { postId } = req.params;

  try {
    const query = `
      SELECT c.id, c.content, c.created_at, u.name AS username
      FROM comments c
      JOIN users u ON c.user_id = u.id
      WHERE c.post_id = $1
      ORDER BY c.created_at ASC
    `;
    const result = await pool.query(query, [postId]);

    const comments = result.rows.map(comment => ({
      id: comment.id,
      username: comment.username,
      content: comment.content,
      timestamp: new Date(comment.created_at).toLocaleString('en-US', {
        hour: 'numeric',
        minute: '2-digit',
        hour12: true,
        month: 'short',
        day: 'numeric',
      }),
    }));

    res.json({ comments });
  } catch (err) {
    console.error('Error fetching comments:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
};

// POST /api/feed/:postId/comments
exports.createComment = async (req, res) => {
  const { postId } = req.params;
  const { userId, content } = req.body;

  if (!userId || !content) {
    return res.status(400).json({ error: 'Missing userId or content' });
  }

  try {
    const query = `
      INSERT INTO comments (post_id, user_id, content)
      VALUES ($1, $2, $3)
      RETURNING id
    `;
    await pool.query(query, [postId, userId, content]);

    res.status(201).json({ message: 'Comment added' });
  } catch (err) {
    console.error('Error adding comment:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
};
