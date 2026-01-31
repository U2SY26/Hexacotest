import { BrowserRouter, Routes, Route } from 'react-router-dom'
import { Suspense, lazy, useState, useEffect } from 'react'
import Layout from './components/layout/Layout'
import LoadingSpinner from './components/common/LoadingSpinner'
import IntroVideo from './components/IntroVideo'

const LandingPage = lazy(() => import('./pages/LandingPage'))
const TestPage = lazy(() => import('./pages/TestPage'))
const ResultPage = lazy(() => import('./pages/ResultPage'))
const PrivacyPage = lazy(() => import('./pages/PrivacyPage'))

function App() {
  const [showIntro, setShowIntro] = useState<boolean | null>(null)

  useEffect(() => {
    const hasSeenIntro = localStorage.getItem('intro_video_shown')
    setShowIntro(!hasSeenIntro)
  }, [])

  const handleIntroComplete = () => {
    localStorage.setItem('intro_video_shown', 'true')
    setShowIntro(false)
  }

  // Loading state
  if (showIntro === null) {
    return (
      <div style={{
        minHeight: '100vh',
        backgroundColor: '#1a1625',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center'
      }}>
        <LoadingSpinner />
      </div>
    )
  }

  // Show intro video
  if (showIntro) {
    return <IntroVideo onComplete={handleIntroComplete} />
  }

  return (
    <BrowserRouter>
      <Layout>
        <Suspense fallback={<LoadingSpinner />}>
          <Routes>
            <Route path="/" element={<LandingPage />} />
            <Route path="/test" element={<TestPage />} />
            <Route path="/result" element={<ResultPage />} />
            <Route path="/privacy" element={<PrivacyPage />} />
          </Routes>
        </Suspense>
      </Layout>
    </BrowserRouter>
  )
}

export default App
