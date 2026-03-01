import { Link } from 'react-router-dom'
import { useTranslation } from 'react-i18next'
import { motion } from 'framer-motion'
import { Globe, Hexagon, BookOpen, HelpCircle } from 'lucide-react'

export default function Header() {
  const { i18n, t } = useTranslation()

  const toggleLanguage = () => {
    const newLang = i18n.language === 'ko' ? 'en' : 'ko'
    i18n.changeLanguage(newLang)
    localStorage.setItem('language', newLang)
  }

  const isKo = i18n.language === 'ko'

  return (
    <motion.header
      initial={{ y: -20, opacity: 0 }}
      animate={{ y: 0, opacity: 1 }}
      className="fixed top-0 left-0 right-0 z-50 glass"
    >
      <div className="max-w-6xl mx-auto px-4 py-3 flex items-center justify-between">
        <Link to="/" className="flex items-center gap-3 group">
          <motion.div
            whileHover={{ rotate: 180 }}
            transition={{ duration: 0.5 }}
            className="w-10 h-10 rounded-xl bg-purple-500/20 flex items-center justify-center"
          >
            <Hexagon className="w-6 h-6 text-purple-500" />
          </motion.div>
          <div className="flex flex-col">
            <span className="text-sm font-bold gradient-text leading-tight">
              {t('header.tagline')}
            </span>
            <span className="text-xs text-gray-400 leading-tight">
              {t('header.subtitle')}
            </span>
          </div>
        </Link>

        <div className="flex items-center gap-2">
          {/* Navigation Links */}
          <Link
            to="/about"
            className="hidden sm:flex items-center gap-1 px-2.5 py-2 rounded-lg text-gray-400 hover:text-white hover:bg-white/5 transition-colors text-sm"
          >
            <BookOpen className="w-3.5 h-3.5" />
            <span>{isKo ? '모델 소개' : 'About'}</span>
          </Link>
          <Link
            to="/faq"
            className="hidden sm:flex items-center gap-1 px-2.5 py-2 rounded-lg text-gray-400 hover:text-white hover:bg-white/5 transition-colors text-sm"
          >
            <HelpCircle className="w-3.5 h-3.5" />
            <span>FAQ</span>
          </Link>

          {/* Language Toggle */}
          <motion.button
            onClick={toggleLanguage}
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
            className="flex items-center gap-2 px-3 py-2 rounded-lg
                       bg-dark-card border border-dark-border
                       hover:border-purple-500/50 transition-colors"
          >
            <Globe className="w-4 h-4 text-gray-400" />
            <span className="text-sm font-medium">
              {i18n.language === 'ko' ? 'EN' : '한국어'}
            </span>
          </motion.button>
        </div>
      </div>
    </motion.header>
  )
}
