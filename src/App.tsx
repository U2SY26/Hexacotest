import { BrowserRouter, Routes, Route } from 'react-router-dom'
import { Suspense, lazy, useState } from 'react'
import Layout from './components/layout/Layout'
import LoadingSpinner from './components/common/LoadingSpinner'
import IntroVideo from './components/IntroVideo'

const LandingPage = lazy(() => import('./pages/LandingPage'))
const TestPage = lazy(() => import('./pages/TestPage'))
const ResultPage = lazy(() => import('./pages/ResultPage'))
const PrivacyPage = lazy(() => import('./pages/PrivacyPage'))

function App() {
  const [showIntro, setShowIntro] = useState(true)

  const handleIntroComplete = () => {
    setShowIntro(false)
  }

  // Show intro video on every visit
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
