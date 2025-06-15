import { createBrowserClient } from "@supabase/ssr"

export function createClient() {
  return createBrowserClient(process.env.NEXT_PUBLIC_SUPABASE_URL, process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY)
}

// Client-side login function
export async function loginClient({ email, password }) {
  const supabase = createClient()

  try {
    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password,
    })

    if (error) {
      console.error("Login error:", error.message)
      return error.message
    }

    return true
  } catch (error) {
    console.error("Unexpected login error:", error)
    return "An unexpected error occurred during login"
  }
}

// Google OAuth login
export async function loginWithGoogle() {
  const supabase = createClient()

  try {
    const { data, error } = await supabase.auth.signInWithOAuth({
      provider: "google",
      options: {
        redirectTo: `${window.location.origin}/auth/callback`,
      },
    })

    if (error) {
      console.error("Google login error:", error.message)
      return error.message
    }

    return true
  } catch (error) {
    console.error("Unexpected Google login error:", error)
    return "An unexpected error occurred during Google login"
  }
}

// Sign out function
export async function signOut() {
  const supabase = createClient()

  try {
    const { error } = await supabase.auth.signOut()

    if (error) {
      console.error("Sign out error:", error.message)
      return error.message
    }

    return true
  } catch (error) {
    console.error("Unexpected sign out error:", error)
    return "An unexpected error occurred during sign out"
  }
}

// Get current user - handles no session gracefully
export async function getCurrentUser() {
  const supabase = createClient()

  try {
    const {
      data: { user },
      error,
    } = await supabase.auth.getUser()

    // If there's an error related to no session, return null (not logged in)
    if (error) {
      if (
        error.message.includes("Auth session missing") ||
        error.message.includes("JWT") ||
        error.message.includes("session")
      ) {
        // This is normal when user is not logged in
        return null
      }
      console.error("Get user error:", error.message)
      return null
    }

    return user
  } catch (error) {
    console.error("Unexpected get user error:", error)
    return null
  }
}

// Listen to auth state changes
export function onAuthStateChange(callback) {
  const supabase = createClient()

  return supabase.auth.onAuthStateChange((event, session) => {
    callback(event, session)
  })
}
