import { ReactNode } from 'react'
import Header from './Header'

interface LayoutProps {
  children: ReactNode
}

export default function Layout({ children }: LayoutProps) {
  return (
    <div className="min-h-screen bg-dark-bg animated-gradient">
      <Header />
      <main>{children}</main>
    </div>
  )
}
