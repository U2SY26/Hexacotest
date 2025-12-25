import { Link } from 'react-router-dom'
import { useTranslation } from 'react-i18next'
import { motion } from 'framer-motion'
import { Brain, Users, Share2, Sparkles, ChevronRight, Hexagon } from 'lucide-react'
import { useTestStore } from '../stores/testStore'

const fadeInUp = {
  initial: { opacity: 0, y: 20 },
  animate: { opacity: 1, y: 0 },
  transition: { duration: 0.6 }
}

const staggerContainer = {
  animate: {
    transition: {
      staggerChildren: 0.1
    }
  }
}

export default function LandingPage() {
  const { t } = useTranslation()
  const reset = useTestStore(state => state.reset)

  const features = [
    { icon: Brain, key: 'scientific' },
    { icon: Users, key: 'persona' },
    { icon: Share2, key: 'share' },
  ]

  const hexacoFactors = ['H', 'E', 'X', 'A', 'C', 'O'] as const

  return (
    <div className="min-h-screen pt-20">
      {/* Hero Section */}
      <section className="relative overflow-hidden py-20 md:py-32">
        {/* Animated background elements */}
        <div className="absolute inset-0 overflow-hidden">
          <motion.div
            className="absolute top-20 left-10 w-72 h-72 bg-purple-500/10 rounded-full blur-3xl"
            animate={{
              scale: [1, 1.2, 1],
              opacity: [0.3, 0.5, 0.3],
            }}
            transition={{ duration: 8, repeat: Infinity }}
          />
          <motion.div
            className="absolute bottom-20 right-10 w-96 h-96 bg-pink-500/10 rounded-full blur-3xl"
            animate={{
              scale: [1.2, 1, 1.2],
              opacity: [0.3, 0.5, 0.3],
            }}
            transition={{ duration: 8, repeat: Infinity, delay: 1 }}
          />
        </div>

        <div className="relative max-w-6xl mx-auto px-4 text-center">
          <motion.div
            initial={{ opacity: 0, scale: 0.8 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ duration: 0.8 }}
            className="mb-8"
          >
            <motion.div
              animate={{ rotate: 360 }}
              transition={{ duration: 20, repeat: Infinity, ease: 'linear' }}
              className="inline-block"
            >
              <Hexagon className="w-20 h-20 md:w-24 md:h-24 text-purple-500 mx-auto" strokeWidth={1.5} />
            </motion.div>
          </motion.div>

          <motion.h1
            {...fadeInUp}
            className="text-5xl md:text-7xl font-bold mb-4"
          >
            <span className="gradient-text">{t('landing.title')}</span>
          </motion.h1>

          <motion.h2
            {...fadeInUp}
            transition={{ delay: 0.1 }}
            className="text-3xl md:text-5xl font-bold text-white mb-6"
          >
            {t('landing.subtitle')}
          </motion.h2>

          <motion.p
            {...fadeInUp}
            transition={{ delay: 0.2 }}
            className="text-lg md:text-xl text-gray-400 max-w-2xl mx-auto mb-10 whitespace-pre-line"
          >
            {t('landing.description')}
          </motion.p>

          <motion.div
            {...fadeInUp}
            transition={{ delay: 0.3 }}
          >
            <Link
              to="/test"
              onClick={() => reset()}
              className="btn-primary inline-flex items-center gap-2 text-lg"
            >
              <Sparkles className="w-5 h-5" />
              {t('landing.cta')}
              <ChevronRight className="w-5 h-5" />
            </Link>
          </motion.div>
        </div>
      </section>

      {/* Features Section */}
      <section className="py-20">
        <div className="max-w-6xl mx-auto px-4">
          <motion.div
            variants={staggerContainer}
            initial="initial"
            whileInView="animate"
            viewport={{ once: true }}
            className="grid md:grid-cols-3 gap-6"
          >
            {features.map(({ icon: Icon, key }) => (
              <motion.div
                key={key}
                variants={fadeInUp}
                className="card group"
              >
                <div className="w-14 h-14 rounded-xl bg-gradient-to-br from-purple-500/20 to-pink-500/20
                              flex items-center justify-center mb-4
                              group-hover:from-purple-500/30 group-hover:to-pink-500/30 transition-all">
                  <Icon className="w-7 h-7 text-purple-400" />
                </div>
                <h3 className="text-xl font-bold text-white mb-2">
                  {t(`landing.features.${key}.title`)}
                </h3>
                <p className="text-gray-400">
                  {t(`landing.features.${key}.description`)}
                </p>
              </motion.div>
            ))}
          </motion.div>
        </div>
      </section>

      {/* HEXACO Explanation Section */}
      <section className="py-20">
        <div className="max-w-6xl mx-auto px-4">
          <motion.div
            initial={{ opacity: 0 }}
            whileInView={{ opacity: 1 }}
            viewport={{ once: true }}
            className="text-center mb-12"
          >
            <h2 className="text-3xl md:text-4xl font-bold text-white mb-4">
              {t('landing.hexaco.title')}
            </h2>
            <p className="text-gray-400 max-w-3xl mx-auto">
              {t('landing.hexaco.description')}
            </p>
          </motion.div>

          <motion.div
            variants={staggerContainer}
            initial="initial"
            whileInView="animate"
            viewport={{ once: true }}
            className="grid md:grid-cols-2 lg:grid-cols-3 gap-4"
          >
            {hexacoFactors.map((factor) => (
              <motion.div
                key={factor}
                variants={fadeInUp}
                className="card relative overflow-hidden"
              >
                <div className="absolute top-0 right-0 text-8xl font-bold text-white/5">
                  {factor}
                </div>
                <div className="relative">
                  <div className="flex items-center gap-3 mb-3">
                    <span className="text-3xl font-bold gradient-text">{factor}</span>
                    <div>
                      <p className="font-semibold text-white">
                        {t(`landing.hexaco.factors.${factor}.name`)}
                      </p>
                      <p className="text-sm text-gray-500">
                        {t(`landing.hexaco.factors.${factor}.full`)}
                      </p>
                    </div>
                  </div>
                  <p className="text-gray-400 text-sm">
                    {t(`landing.hexaco.factors.${factor}.desc`)}
                  </p>
                </div>
              </motion.div>
            ))}
          </motion.div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-20">
        <div className="max-w-4xl mx-auto px-4 text-center">
          <motion.div
            initial={{ opacity: 0, scale: 0.95 }}
            whileInView={{ opacity: 1, scale: 1 }}
            viewport={{ once: true }}
            className="card bg-gradient-to-br from-purple-900/50 to-pink-900/50 border-purple-500/30"
          >
            <h2 className="text-2xl md:text-3xl font-bold text-white mb-4">
              지금 바로 나의 성격을 알아보세요
            </h2>
            <p className="text-gray-300 mb-6">
              60문항의 테스트를 통해 당신의 HEXACO 성격 프로필을 확인하세요
            </p>
            <Link
              to="/test"
              onClick={() => reset()}
              className="btn-primary inline-flex items-center gap-2"
            >
              {t('common.start')}
              <ChevronRight className="w-5 h-5" />
            </Link>
          </motion.div>
        </div>
      </section>

      {/* Footer */}
      <footer className="py-8 border-t border-dark-border">
        <div className="max-w-6xl mx-auto px-4 text-center text-gray-500 text-sm">
          <p>HEXACO Personality Test</p>
          <p className="mt-1">Based on HEXACO-PI-R by Ashton & Lee</p>
        </div>
      </footer>
    </div>
  )
}
