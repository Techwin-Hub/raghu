const express = require('express');
const router = express.Router();
const multer = require('multer');
const bcrypt = require('bcrypt');
const db = require('../db');

const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        cb(null, 'uploads/');
    },
    filename: function (req, file, cb) {
        const ext = file.originalname.split('.').pop();
        cb(null, req.body.phone + '.' + ext);
    }
});

const upload = multer({ storage: storage });

router.post('/signup', upload.single('profileImage'), async (req, res) => {
    const { firstName, lastName, email, phone, password } = req.body;
    const imagePath = req.file ? req.file.path : '';

    if (!firstName || !lastName || !email || !phone || !password || !imagePath) {
        return res.status(400).json({ message: 'Missing fields' });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    db.run(`INSERT INTO users (firstName, lastName, email, phone, password, imagePath)
            VALUES (?, ?, ?, ?, ?, ?)`,
        [firstName, lastName, email, phone, hashedPassword, imagePath],
        function (err) {
            if (err) {
                console.error(err);
                return res.status(500).json({ message: 'Signup failed' });
            }
            return res.status(200).json({ message: 'Signup successful' });
        }
    );
});

router.post('/signin', (req, res) => {
    const { username, password } = req.body;
    if (!username || !password) {
        return res.status(400).json({ message: 'Missing credentials' });
    }

    const query = username.includes('@') ? 'email = ?' : 'phone = ?';
    db.get(`SELECT * FROM users WHERE ${query}`, [username], async (err, user) => {
        if (err || !user) {
            return res.status(401).json({ message: 'Invalid username or password' });
        }

        const passwordMatch = await bcrypt.compare(password, user.password);
        if (passwordMatch) {
            return res.status(200).json({ message: 'Login successful' });
        } else {
            return res.status(401).json({ message: 'Invalid username or password' });
        }
    });
});

module.exports = router;
