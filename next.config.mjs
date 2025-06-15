/** @type {import('next').NextConfig} */
const nextConfig = {
    compress: true, // Enables built-in text compression (Gzip/Brotli)
    images: {
      remotePatterns: [
        {
          protocol: 'https',
          hostname: '3vsrvtbwvqgcv6z1.public.blob.vercel-storage.com',
          port: '',
          pathname: '/**',    // allow any path in this specific Blob store
        },
        {
          protocol: 'https',
          hostname: '*.public.blob.vercel-storage.com',
          port: '',
          pathname: '/**',    // wildcard for any other Blob stores you might add
        },
        {
          protocol: 'https',
          hostname: 'blob.vercel-storage.com',
          port: '',
          pathname: '/**',    // if you need the generic domain as well
        },
      ],
    },
  }
  
  export default nextConfig
