import { useState } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { Save, AlertTriangle } from 'lucide-react'

interface SavePromptDialogProps {
  isOpen: boolean
  onSave: () => void
  onDiscard: () => void
  onCancel: () => void
  isKo: boolean
}

export default function SavePromptDialog({ isOpen, onSave, onDiscard, onCancel, isKo }: SavePromptDialogProps) {
  const [stage, setStage] = useState<'prompt' | 'warning'>('prompt')

  const handleNo = () => setStage('warning')
  const handleGoBack = () => {
    setStage('prompt')
  }
  const handleLeave = () => {
    setStage('prompt')
    onDiscard()
  }
  const handleSave = () => {
    setStage('prompt')
    onSave()
  }
  const handleCancel = () => {
    setStage('prompt')
    onCancel()
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
          onClick={handleCancel}
        >
          <motion.div
            initial={{ scale: 0.9, opacity: 0 }}
            animate={{ scale: 1, opacity: 1 }}
            exit={{ scale: 0.9, opacity: 0 }}
            className="w-full max-w-sm rounded-2xl border border-white/10 p-6"
            style={{ backgroundColor: '#1A1A2E' }}
            onClick={(e) => e.stopPropagation()}
          >
            {stage === 'prompt' ? (
              <div className="text-center">
                <Save className="w-10 h-10 text-purple-400 mx-auto mb-4" />
                <h3 className="text-lg font-bold text-white mb-2">
                  {isKo ? '결과를 저장하시겠습니까?' : 'Save your result?'}
                </h3>
                <p className="text-sm text-gray-400 mb-6">
                  {isKo
                    ? '4자리 PIN으로 보호하여 나중에 다시 볼 수 있습니다.'
                    : 'Protect with a 4-digit PIN to view later.'}
                </p>
                <div className="flex gap-3">
                  <button
                    onClick={handleNo}
                    className="flex-1 py-3 rounded-xl border border-white/10 text-white/70 font-semibold hover:bg-white/5 transition-colors"
                  >
                    {isKo ? '아니오' : 'No'}
                  </button>
                  <button
                    onClick={handleSave}
                    className="flex-1 py-3 rounded-xl font-semibold text-white transition-colors"
                    style={{
                      background: 'linear-gradient(to right, #7C3AED, #DB2777)',
                    }}
                  >
                    {isKo ? '저장하기' : 'Save'}
                  </button>
                </div>
              </div>
            ) : (
              <div className="text-center">
                <AlertTriangle className="w-10 h-10 text-orange-500 mx-auto mb-4" />
                <h3 className="text-lg font-bold text-white mb-2">
                  {isKo ? '정말 나가시겠습니까?' : 'Are you sure?'}
                </h3>
                <p className="text-sm text-red-400 mb-6">
                  {isKo
                    ? '저장하지 않으면 결과가 영구적으로 사라집니다.'
                    : 'Your result will be permanently lost.'}
                </p>
                <div className="flex gap-3">
                  <button
                    onClick={handleGoBack}
                    className="flex-1 py-3 rounded-xl border border-white/10 text-white/70 font-semibold hover:bg-white/5 transition-colors"
                  >
                    {isKo ? '돌아가기' : 'Go Back'}
                  </button>
                  <button
                    onClick={handleLeave}
                    className="flex-1 py-3 rounded-xl font-semibold text-red-400 transition-colors"
                    style={{ backgroundColor: 'rgba(239, 68, 68, 0.2)' }}
                  >
                    {isKo ? '나가기' : 'Leave'}
                  </button>
                </div>
              </div>
            )}
          </motion.div>
        </motion.div>
      )}
    </AnimatePresence>
  )
}
