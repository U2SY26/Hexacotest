import { Link } from 'react-router-dom'
import { motion } from 'framer-motion'
import { ArrowLeft } from 'lucide-react'

export default function PrivacyPage() {
  return (
    <div className="min-h-screen pt-24 pb-12 px-4">
      <div className="max-w-3xl mx-auto">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
        >
          <Link
            to="/"
            className="inline-flex items-center gap-2 text-gray-400 hover:text-white mb-8"
          >
            <ArrowLeft className="w-4 h-4" />
            홈으로 돌아가기
          </Link>

          <h1 className="text-3xl font-bold text-white mb-8">개인정보처리방침</h1>

          <div className="prose prose-invert max-w-none space-y-6 text-gray-300">
            <section>
              <h2 className="text-xl font-semibold text-white mb-3">1. 개인정보의 수집 및 이용 목적</h2>
              <p>
                HEXACO 성격 테스트(이하 "서비스")는 사용자의 개인정보를 수집하지 않습니다.
                테스트 결과는 사용자의 브라우저에만 저장되며, 서버로 전송되지 않습니다.
              </p>
            </section>

            <section>
              <h2 className="text-xl font-semibold text-white mb-3">2. 수집하는 개인정보 항목</h2>
              <p>
                본 서비스는 별도의 회원가입 없이 이용 가능하며, 개인정보를 수집하지 않습니다.
                테스트 응답 데이터는 로컬 스토리지에만 저장됩니다.
              </p>
            </section>

            <section>
              <h2 className="text-xl font-semibold text-white mb-3">3. 쿠키 및 광고</h2>
              <p>
                본 서비스는 Google AdSense를 통해 광고를 게재합니다.
                Google은 사용자의 관심사에 맞는 광고를 제공하기 위해 쿠키를 사용할 수 있습니다.
                사용자는 <a href="https://www.google.com/settings/ads" target="_blank" rel="noopener noreferrer" className="text-purple-400 hover:text-purple-300">Google 광고 설정</a>에서 맞춤 광고를 거부할 수 있습니다.
              </p>
            </section>

            <section>
              <h2 className="text-xl font-semibold text-white mb-3">4. 개인정보의 보유 및 이용 기간</h2>
              <p>
                테스트 결과는 사용자의 브라우저 로컬 스토리지에 저장되며,
                브라우저 데이터 삭제 시 함께 삭제됩니다.
              </p>
            </section>

            <section>
              <h2 className="text-xl font-semibold text-white mb-3">5. 개인정보 보호 책임자</h2>
              <p>
                서비스 이용 중 개인정보 관련 문의사항이 있으시면 아래 연락처로 문의해 주세요.
              </p>
              <p className="mt-2">
                게시자 ID: pub-2988937021017804
              </p>
            </section>

            <section>
              <h2 className="text-xl font-semibold text-white mb-3">6. 개인정보처리방침의 변경</h2>
              <p>
                본 개인정보처리방침은 2025년 12월 25일부터 적용됩니다.
                법령 및 방침에 따른 변경 내용의 추가, 삭제 및 정정이 있는 경우에는
                변경사항의 시행 7일 전부터 공지사항을 통하여 고지할 것입니다.
              </p>
            </section>
          </div>
        </motion.div>
      </div>
    </div>
  )
}
