import { createClient } from '@supabase/supabase-js';

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY // Safe here because it's server-side
);

export async function POST(request) {
  try {
    const body = await request.json();
    const { user_id, name, description, nodes, edges } = body;

    if (!user_id || !name || !nodes || !edges) {
      return new Response(JSON.stringify({ error: 'Missing required fields' }), { status: 400 });
    }

    const { data, error } = await supabase
      .from('projects')
      .insert([{ user_id, name, description, nodes, edges }])
      .select(); // return inserted row

    if (error) {
      return new Response(JSON.stringify({ error: error.message }), { status: 500 });
    }

    return new Response(JSON.stringify({ project: data[0] }), { status: 201 });
  } catch (err) {
    return new Response(JSON.stringify({ error: err.message }), { status: 500 });
  }
}
