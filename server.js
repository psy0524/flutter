const express = require('express');
const cors = require('cors');
const mongoose = require('mongoose');

const app = express();
const port = 3000;

// CORS 허용
app.use(cors());

// JSON 파싱 미들웨어
app.use(express.json());

// MongoDB 연결 설정
const mongoUri = 'mongodb://localhost:27017/sunmoonApp';  // MongoDB 연결 URI
mongoose.connect(mongoUri)
  .then(() => console.log('MongoDB 연결 성공'))
  .catch(err => console.error('MongoDB 연결 실패:', err));

// Mongoose 스키마 설정
const userSchema = new mongoose.Schema({
  user_id: String,
  password: String,
});

const User = mongoose.model('User', userSchema);

// /users 경로에서 사용자 정보 가져오기 (GET 요청)
app.get('/users', async (req, res) => {
  try {
    const users = await User.find();
    res.json(users);  // 사용자 정보 JSON 형식으로 응답
  } catch (error) {
    res.status(500).json({ error: '사용자 정보를 가져오는 데 실패했습니다.' });
  }
});

// /users 경로에서 사용자 정보 추가하기 (POST 요청)
app.post('/users', async (req, res) => {
  const { user_id, password } = req.body;

  try {
    const newUser = new User({ user_id, password });
    await newUser.save();  // MongoDB에 사용자 저장
    res.status(201).json({ message: '사용자 등록 성공', user: newUser });
  } catch (error) {
    res.status(500).json({ error: '사용자 등록 실패' });
  }
});

// /login 경로에서 로그인 처리 (POST 요청)
app.post('/login', async (req, res) => {
  const { user_id, password } = req.body;

  try {
    const user = await User.findOne({ user_id, password }); // 사용자 찾기
    if (user) {
      res.status(200).json({ message: '로그인 성공' });
    } else {
      res.status(401).json({ error: '아이디 또는 비밀번호가 잘못되었습니다.' }); // 401 Unauthorized
    }
  } catch (error) {
    res.status(500).json({ error: '로그인 처리 중 오류가 발생했습니다.' });
  }
});

// 서버 실행
app.listen(port, () => {
  console.log(`Server running on http://localhost:${port}`);
});
