const fetch = require('node-fetch');

module.exports = async (req, res) => {
  if (req.method !== 'POST') {
    res.status(405).json({ error: 'Method Not Allowed' });
    return;
  }

  const { messages, model = 'gpt-3.5-turbo', max_tokens = 500, temperature = 0.7 } = req.body;
  const apiKey = process.env.OPENAI_API_KEY;

  if (!apiKey) {
    res.status(500).json({ error: 'OpenAI API key not set in environment variables.' });
    return;
  }

  try {
    const openaiRes = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${apiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model,
        messages,
        max_tokens,
        temperature,
      }),
    });

    const data = await openaiRes.json();
    res.status(openaiRes.status).json(data);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}; 