import { motion } from 'framer-motion'

export default function LoadingSpinner() {
  return (
    <div className="min-h-screen flex items-center justify-center">
      <motion.div
        className="w-16 h-16 border-4 border-purple-500/30 border-t-purple-500 rounded-full"
        animate={{ rotate: 360 }}
        transition={{ duration: 1, repeat: Infinity, ease: 'linear' }}
      />
    </div>
  )
}
