import { deepseek } from '@/lib/deepseekClient';

export const runtime = 'edge';

export async function POST(req) {
  try {
    const { currQuestion, currAnswer } = await req.json();

    const prompt = `
    You are an expert evaluator for a learning system. Assess the user's short answer response to the following question.

    Question:
    "${currQuestion}"

    User's Answer:
    "${currAnswer}"

    Task:
    1. Determine if the user's answer is sufficiently correct based on the question context.
    2. Respond in **this exact format**:
    ---
    Verdict: Correct | Incorrect
    Reason: [Explain why it is correct or incorrect. Include any missing or relevant context.]
    ---
    Only respond in the format above. Do not include any other commentary.
    `;

    const completion = await deepseek.chat.completions.create({
      model: 'deepseek-chat',
      messages: [{ role: 'user', content: prompt }],
    });

    const text = completion.choices[0].message.content || 'No response generated';
    return new Response(text, {
      headers: { 'Content-Type': 'text/plain' },
    });
  } catch (error) {
    console.error('simulateNode error:', error);
    return new Response('Internal Server Error', { status: 500 });
  }
}
