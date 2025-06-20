module.exports = function requireLogin(req, res, next) {
  if (req.session && req.session.userId) {
    // ✅ User is authenticated
    return next();
  }

  // ❌ User is not authenticated
  return res.status(401).json({ message: 'Unauthorized: Please log in first.' });
};
 
