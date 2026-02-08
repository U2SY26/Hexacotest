import { useState, useRef, useEffect } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { X } from 'lucide-react'

interface PinDialogProps {
  isOpen: boolean
  onClose: () => void
  onConfirm: (pin: string) => void
  title: string
  subtitle?: string
  error?: string
}

export default function PinDialog({ isOpen, onClose, onConfirm, title, subtitle, error }: PinDialogProps) {
  const [pin, setPin] = useState('')
  const inputRef = useRef<HTMLInputElement>(null)

  useEffect(() => {
    if (isOpen) {
      setPin('')
      setTimeout(() => inputRef.current?.focus(), 100)
    }
  }, [isOpen])

  const handleChange = (value: string) => {
    const digits = value.replace(/\D/g, '').slice(0, 4)
    setPin(digits)
    if (digits.length === 4) {
      setTimeout(() => onConfirm(digits), 150)
    }
  }

  return (
    <AnimatePresence>
      {isOpen && (
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          className="fixed inset-0 z-50 flex items-center justify-center p-4"
          style={{ backgroundColor: 'rgba(0,0,0,0.7)' }}
        >
          <motion.div
            initial={{ scale: 0.9, opacity: 0 }}
            animate={{ scale: 1, opacity: 1 }}
            exit={{ scale: 0.9, opacity: 0 }}
            className="w-full max-w-xs rounded-2xl border border-white/10 p-6"
            style={{ backgroundColor: '#1A1A2E' }}
          >
            <div className="flex justify-end">
              <button onClick={onClose} className="text-gray-500 hover:text-white transition-colors">
                <X className="w-5 h-5" />
              </button>
            </div>

            <div className="text-center mb-6">
              <h3 className="text-lg font-bold text-white mb-1">{title}</h3>
              {subtitle && <p className="text-sm text-gray-400">{subtitle}</p>}
            </div>

            <div className="flex justify-center gap-3 mb-6">
              {[0, 1, 2, 3].map((i) => (
                <div
                  key={i}
                  className={`w-4 h-4 rounded-full border-2 transition-colors ${
                    i < pin.length
                      ? 'bg-purple-500 border-purple-500'
                      : 'bg-transparent border-gray-600'
                  }`}
                />
              ))}
            </div>

            <input
              ref={inputRef}
              type="tel"
              inputMode="numeric"
              maxLength={4}
              value={pin}
              onChange={(e) => handleChange(e.target.value)}
              className="w-full text-center text-2xl tracking-[1em] bg-white/5 border border-white/10 rounded-xl py-3 text-white outline-none focus:border-purple-500 transition-colors"
              autoComplete="off"
            />

            {error && (
              <p className="text-red-400 text-sm text-center mt-3">{error}</p>
            )}
          </motion.div>
        </motion.div>
      )}
    </AnimatePresence>
  )
}
