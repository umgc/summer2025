import { deepseek } from '@/lib/deepseekClient';

export const runtime = 'edge';

export async function POST(req) {
  try {
    const { node } = await req.json();

    // Build prompt body for quiz
    let quizPrompt = '';
    if (node.type === 'quiz' && Array.isArray(node.data.questions)) {
      quizPrompt = node.data.questions.map((q, index) => {
        return `Q${index + 1}: ${q.question}
Options: ${q.options.join(', ')}`;
      }).join('\n\n');
    }
    console.log('Quiz prompt:', quizPrompt);

    const prompt = `
Simulate a user interacting with the following node in a learning workflow:

Type: ${node.type}
Title: ${node.data.title || 'N/A'}
Label: ${node.data.label || 'N/A'}
Description: ${node.data.description || 'N/A'}

${quizPrompt}

Respond with the most likely action or answer the user would take.
Please respond with the user's selected answer using this format:
**Answer: [chosen option]**
Respond only in the format above. Do not add any explanation or context.
`;

    const completion = await deepseek.chat.completions.create({
      model: 'deepseek-chat',
      messages: [{ role: 'user', content: prompt }],
    });

    const text = completion.choices[0].message.content;
    return new Response(text, {
      headers: { 'Content-Type': 'text/plain' },
    });
  } catch (error) {
    console.error('simulateNode error:', error);
    return new Response('Internal Server Error', { status: 500 });
  }
}
