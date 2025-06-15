import { NextResponse } from 'next/server'
// The client you created from the Server-Side Auth instructions
import { createClient } from '@/utils/supabase/server'
//import { supabase } from '@/lib/supabaseClient'

export async function GET(request) {
  const { searchParams, origin } = new URL(request.url)
  const code = searchParams.get('code')
  const next = searchParams.get('next') ?? '/'
  console.log("Auth Callback")

  if (code) {
    const supabase = await createClient()
    const { error } = await supabase.auth.exchangeCodeForSession(code) //Sets cookies
    console.log("Exchange Code for Session Result:", error)
    if (!error) {

      const { data: { user } } = await supabase.auth.getUser();
      console.log("User Data:", user)
      if (!user) {
        return NextResponse.redirect(`${origin}/auth/auth-code-error`);
      }

      //Get user profile ID from profiles table
      const { data: profile, error: profileError } = await supabase
        .from('profiles')
        .select('id')
        .eq('id', user.id)
        .single()

      if (profileError || !profile) {
        const fullName = user.user_metadata.full_name || "";
        const [firstName, ...rest] = fullName.split(' ')
        const lastName = rest.join(' ') || '';
        console.log("Creating new profile for user:", user.id)
        console.log("Full Name:", fullName)

        // Insert into profiles table manually
        const { error: insertError } = await supabase.from('profiles').insert({
          id: user.id,
          email: user.email,
          displayName: fullName,
          firstName,
          lastName,
          plan: 'free',
          signup_source: 'google',
        })
        console.log("Profile Insert Result:", insertError)
        if (insertError) {
          console.error("Insert Error:", insertError)
        }
        
      }

      // 🔍 Get user session and ID
      const userId = user?.id
      console.log("User ID:", userId)

      if (userId) {
        // 📦 Fetch the user's profile plan
        const { data: profile, error: profileError } = await supabase
          .from('profiles')
          .select('plan')
          .eq('id', userId)
          .single()
        
        // ✅ If user has no subscription, send to subscription page
        if (!profile || profile.plan === 'free') {
          return NextResponse.redirect(`${origin}/`)
        }

        // ✅ Otherwise, send to dashboard or app
        return NextResponse.redirect(`${origin}${next}`)
      }

      // Fallback if session fails
      return NextResponse.redirect(`${origin}/`)
    }
  } else {
    // If no code is provided, redirect to error page
    console.error("No code provided in the request:", error)
  }

  // return the user to an error page with instructions
  return NextResponse.redirect(`${origin}/auth/auth-code-error`)
}