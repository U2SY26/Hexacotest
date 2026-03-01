import { BrowserRouter, Routes, Route } from 'react-router-dom'
import { Suspense, lazy, useState } from 'react'
import Layout from './components/layout/Layout'
import LoadingSpinner from './components/common/LoadingSpinner'
import IntroVideo from './components/IntroVideo'

const LandingPage = lazy(() => import('./pages/LandingPage'))
const TestPage = lazy(() => import('./pages/TestPage'))
const ResultPage = lazy(() => import('./pages/ResultPage'))
const PrivacyPage = lazy(() => import('./pages/PrivacyPage'))
const AboutPage = lazy(() => import('./pages/AboutPage'))
const FaqPage = lazy(() => import('./pages/FaqPage'))

function App() {
  // Show intro video only on first visit (never block returning users)
  const hasSeenIntro = localStorage.getItem('hexaco_intro_seen') === 'true'
  const [showIntro, setShowIntro] = useState(!hasSeenIntro)

  const handleIntroComplete = () => {
    localStorage.setItem('hexaco_intro_seen', 'true')
    setShowIntro(false)
  }

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
            <Route path="/about" element={<AboutPage />} />
            <Route path="/faq" element={<FaqPage />} />
          </Routes>
        </Suspense>
      </Layout>
    </BrowserRouter>
  )
}

export default App
