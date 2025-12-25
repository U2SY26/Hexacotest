import { Link } from 'react-router-dom'
import { useTranslation } from 'react-i18next'
import { motion } from 'framer-motion'
import { Globe, Hexagon } from 'lucide-react'

export default function Header() {
  const { i18n } = useTranslation()

  const toggleLanguage = () => {
    const newLang = i18n.language === 'ko' ? 'en' : 'ko'
    i18n.changeLanguage(newLang)
    localStorage.setItem('language', newLang)
  }

  return (
    <motion.header
      initial={{ y: -20, opacity: 0 }}
      animate={{ y: 0, opacity: 1 }}
      className="fixed top-0 left-0 right-0 z-50 glass"
    >
      <div className="max-w-6xl mx-auto px-4 py-4 flex items-center justify-between">
        <Link to="/" className="flex items-center gap-2 group">
          <motion.div
            whileHover={{ rotate: 180 }}
            transition={{ duration: 0.5 }}
          >
            <Hexagon className="w-8 h-8 text-purple-500" />
          </motion.div>
          <span className="text-xl font-bold gradient-text">HEXACO</span>
        </Link>

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
    </motion.header>
  )
}
