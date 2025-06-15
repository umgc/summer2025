import { Geist, Geist_Mono, Montserrat, Poppins, Roboto, Oswald, Inter } from "next/font/google"
import "./globals.css"

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
})

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
})

const poppins = Poppins({
  variable: "--font-poppins",
  subsets: ["latin"],
  weight: ["100", "200", "300", "400", "500", "600", "700", "800", "900"],
})

const montserrat = Montserrat({
  variable: "--font-montserrat",
  subsets: ["latin"],
  weight: ["100", "200", "300", "400", "500", "600", "700", "800", "900"],
})

const roboto = Roboto({
  variable: "--font-roboto",
  subsets: ["latin"],
  weight: ["100", "200", "300", "400", "500", "600", "700", "800", "900"],
})

const oswald = Oswald({
  variable: "--font-oswald",
  subsets: ["latin"],
  weight: ["200", "300", "400", "500", "600", "700"],
})

const inter = Inter({
  variable: "--font-inter",
  subsets: ["latin"],
  weight: ["100", "200", "300", "400", "500", "600", "700", "800", "900"],
})

export const metadata = {
  title: "DeepTrain - AI-Powered Learning Platform",
  description:
    "Transform your learning journey with personalized AI-powered education and cutting-edge development tools designed for modern professionals.",
}

export default async function RootLayout({ children }) {
  return (
    <html className="text-center" lang="en">
      <body
        className={`
          ${geistSans.variable} 
          ${geistMono.variable}
          ${poppins.variable}
          ${montserrat.variable}
          ${roboto.variable}
          ${oswald.variable}
          ${inter.variable}
      `}
      >
        {children}
      </body>
    </html>
  )
}
