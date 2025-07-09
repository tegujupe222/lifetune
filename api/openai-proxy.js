const fetch = require('node-fetch');

module.exports = async (req, res) => {
  // CORSヘッダーを設定
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  // OPTIONSリクエストの処理
  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }

  if (req.method !== 'POST') {
    console.log(`Method not allowed: ${req.method}`);
    res.status(405).json({ error: 'Method Not Allowed' });
    return;
  }

  const { messages, model = 'gpt-3.5-turbo', max_tokens = 500, temperature = 0.7 } = req.body;
  const apiKey = process.env.OPENAI_API_KEY;

  console.log('Request received:', {
    model,
    max_tokens,
    temperature,
    messagesCount: messages?.length || 0,
    hasApiKey: !!apiKey
  });

  if (!apiKey) {
    console.error('OpenAI API key not found in environment variables');
    res.status(500).json({ error: 'OpenAI API key not set in environment variables.' });
    return;
  }

  try {
    console.log('Sending request to OpenAI API...');
    
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
    
    console.log('OpenAI API response status:', openaiRes.status);
    console.log('OpenAI API response:', {
      hasChoices: !!data.choices,
      choicesCount: data.choices?.length || 0,
      hasError: !!data.error
    });

    if (!openaiRes.ok) {
      console.error('OpenAI API error:', data);
      res.status(openaiRes.status).json(data);
      return;
    }

    res.status(200).json(data);
  } catch (error) {
    console.error('Error calling OpenAI API:', error);
    res.status(500).json({ error: error.message });
  }
}; 