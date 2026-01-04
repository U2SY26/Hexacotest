import { Link } from 'react-router-dom'
import { motion } from 'framer-motion'
import { ArrowLeft } from 'lucide-react'

export default function PrivacyPage() {
  return (
    <div className="min-h-screen pt-24 pb-12 px-4">
      <div className="max-w-4xl mx-auto">
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

          <h1 className="text-3xl font-bold text-white mb-2">Privacy Policy</h1>
          <p className="text-gray-400 mb-8">개인정보처리방침</p>

          <div className="prose prose-invert max-w-none space-y-8 text-gray-300">

            {/* Last Updated */}
            <div className="bg-dark-card rounded-lg p-4 border border-gray-700">
              <p className="text-sm text-gray-400">
                <strong>Last Updated / 최종 수정일:</strong> December 28, 2024
              </p>
              <p className="text-sm text-gray-400">
                <strong>Effective Date / 시행일:</strong> December 25, 2024
              </p>
            </div>

            {/* Introduction */}
            <section>
              <h2 className="text-xl font-semibold text-white mb-3">1. Introduction / 소개</h2>
              <p className="mb-3">
                HEXACO Personality Test ("we", "us", or "our") respects your privacy and is committed to protecting your personal data. This privacy policy explains how we collect, use, and safeguard your information when you use our website.
              </p>
              <p>
                HEXACO 성격 테스트("당사")는 귀하의 개인정보를 존중하며 보호하기 위해 최선을 다합니다. 본 개인정보처리방침은 당사 웹사이트 이용 시 귀하의 정보가 어떻게 수집, 사용, 보호되는지 설명합니다.
              </p>
            </section>

            {/* Data Controller */}
            <section>
              <h2 className="text-xl font-semibold text-white mb-3">2. Data Controller / 개인정보 관리자</h2>
              <p className="mb-3">
                <strong>Controller:</strong> HEXACO Personality Test<br />
                <strong>Website:</strong> hexacotest.vercel.app<br />
                <strong>Publisher ID:</strong> pub-2988937021017804
              </p>
              <p>
                For any privacy-related inquiries, you may contact us through the website.
              </p>
            </section>

            {/* Data We Collect */}
            <section>
              <h2 className="text-xl font-semibold text-white mb-3">3. Data We Collect / 수집하는 정보</h2>

              <h3 className="text-lg font-medium text-white mt-4 mb-2">3.1 Data You Provide / 귀하가 제공하는 정보</h3>
              <p className="mb-3">
                <strong>We do NOT collect any personal data directly.</strong> No registration, login, or personal information is required to use our service.
              </p>
              <p className="mb-3">
                <strong>당사는 개인정보를 직접 수집하지 않습니다.</strong> 서비스 이용에 회원가입, 로그인, 개인정보 입력이 필요하지 않습니다.
              </p>

              <h3 className="text-lg font-medium text-white mt-4 mb-2">3.2 Automatically Collected Data / 자동 수집 정보</h3>
              <ul className="list-disc pl-5 space-y-2">
                <li><strong>Test Responses:</strong> Stored locally in your browser (localStorage) only. NOT transmitted to our servers.</li>
                <li><strong>Analytics Data:</strong> Via Google Analytics (anonymized IP, pages visited, session duration)</li>
                <li><strong>Advertising Data:</strong> Via Google AdSense (cookie-based interest categories)</li>
              </ul>
            </section>

            {/* Legal Basis (GDPR) */}
            <section>
              <h2 className="text-xl font-semibold text-white mb-3">4. Legal Basis for Processing (GDPR Article 6) / 처리의 법적 근거</h2>
              <ul className="list-disc pl-5 space-y-2">
                <li><strong>Consent (Article 6(1)(a)):</strong> For advertising cookies and analytics</li>
                <li><strong>Legitimate Interest (Article 6(1)(f)):</strong> For website functionality and security</li>
              </ul>
              <p className="mt-3">
                귀하는 언제든지 쿠키 동의를 철회할 수 있습니다.
              </p>
            </section>

            {/* Cookies */}
            <section>
              <h2 className="text-xl font-semibold text-white mb-3">5. Cookies and Tracking / 쿠키 및 추적 기술</h2>

              <h3 className="text-lg font-medium text-white mt-4 mb-2">5.1 Essential Cookies / 필수 쿠키</h3>
              <p>Required for basic website functionality. Cannot be disabled.</p>

              <h3 className="text-lg font-medium text-white mt-4 mb-2">5.2 Analytics Cookies (Google Analytics)</h3>
              <p className="mb-2">
                We use Google Analytics to understand how visitors interact with our website.
              </p>
              <ul className="list-disc pl-5 space-y-1 text-sm">
                <li>Provider: Google LLC</li>
                <li>Purpose: Traffic analysis, user behavior</li>
                <li>Data: Anonymized IP, pages visited, session data</li>
                <li>Retention: 26 months</li>
              </ul>

              <h3 className="text-lg font-medium text-white mt-4 mb-2">5.3 Advertising Cookies (Google AdSense)</h3>
              <p className="mb-2">
                Google AdSense may use cookies to serve personalized ads based on your interests.
              </p>
              <ul className="list-disc pl-5 space-y-1 text-sm">
                <li>Provider: Google LLC</li>
                <li>Purpose: Personalized advertising</li>
                <li>Opt-out: <a href="https://www.google.com/settings/ads" target="_blank" rel="noopener noreferrer" className="text-purple-400 hover:text-purple-300">Google Ad Settings</a></li>
              </ul>
            </section>

            {/* Your Rights (GDPR) */}
            <section>
              <h2 className="text-xl font-semibold text-white mb-3">6. Your Rights (GDPR) / 귀하의 권리</h2>
              <p className="mb-3">Under the General Data Protection Regulation (GDPR), you have the following rights:</p>
              <ul className="list-disc pl-5 space-y-2">
                <li><strong>Right of Access (Article 15):</strong> Request information about your data</li>
                <li><strong>Right to Rectification (Article 16):</strong> Correct inaccurate data</li>
                <li><strong>Right to Erasure (Article 17):</strong> Request deletion of your data ("Right to be Forgotten")</li>
                <li><strong>Right to Restrict Processing (Article 18):</strong> Limit how we use your data</li>
                <li><strong>Right to Data Portability (Article 20):</strong> Receive your data in a machine-readable format</li>
                <li><strong>Right to Object (Article 21):</strong> Object to processing based on legitimate interests</li>
                <li><strong>Right to Withdraw Consent (Article 7(3)):</strong> Withdraw consent at any time</li>
              </ul>
              <p className="mt-3">
                To exercise your rights, clear your browser's localStorage and cookies, or contact us.
              </p>
            </section>

            {/* Data Retention */}
            <section>
              <h2 className="text-xl font-semibold text-white mb-3">7. Data Retention / 정보 보유 기간</h2>
              <ul className="list-disc pl-5 space-y-2">
                <li><strong>Test Results:</strong> Stored in your browser's localStorage until you delete it</li>
                <li><strong>Analytics Data:</strong> 26 months (Google Analytics default)</li>
                <li><strong>Advertising Data:</strong> Managed by Google per their retention policies</li>
              </ul>
            </section>

            {/* International Transfers */}
            <section>
              <h2 className="text-xl font-semibold text-white mb-3">8. International Data Transfers / 국제 데이터 전송</h2>
              <p>
                Google Analytics and AdSense data may be transferred to and processed in the United States. Google LLC complies with the EU-U.S. Data Privacy Framework.
              </p>
              <p className="mt-2">
                Google Analytics 및 AdSense 데이터는 미국으로 전송될 수 있습니다. Google LLC는 EU-미국 데이터 프라이버시 프레임워크를 준수합니다.
              </p>
            </section>

            {/* Children */}
            <section>
              <h2 className="text-xl font-semibold text-white mb-3">9. Children's Privacy / 아동 개인정보</h2>
              <p>
                Our service is not intended for children under 16. We do not knowingly collect data from children. If you believe a child has provided us with personal data, please contact us.
              </p>
              <p className="mt-2">
                본 서비스는 16세 미만 아동을 대상으로 하지 않습니다. 아동의 개인정보를 수집하지 않습니다.
              </p>
            </section>

            {/* California (CCPA) */}
            <section>
              <h2 className="text-xl font-semibold text-white mb-3">10. California Privacy Rights (CCPA)</h2>
              <p>
                If you are a California resident, you have additional rights under the California Consumer Privacy Act (CCPA):
              </p>
              <ul className="list-disc pl-5 space-y-2 mt-2">
                <li>Right to know what personal information is collected</li>
                <li>Right to delete personal information</li>
                <li>Right to opt-out of the sale of personal information</li>
                <li>Right to non-discrimination for exercising your rights</li>
              </ul>
              <p className="mt-3">
                <strong>We do not sell your personal information.</strong>
              </p>
            </section>

            {/* Changes */}
            <section>
              <h2 className="text-xl font-semibold text-white mb-3">11. Changes to This Policy / 정책 변경</h2>
              <p>
                We may update this privacy policy from time to time. We will notify you of any changes by posting the new policy on this page and updating the "Last Updated" date.
              </p>
              <p className="mt-2">
                본 개인정보처리방침은 변경될 수 있으며, 변경 시 이 페이지에 게시하고 "최종 수정일"을 업데이트합니다.
              </p>
            </section>

            {/* How to Delete Your Data */}
            <section>
              <h2 className="text-xl font-semibold text-white mb-3">12. How to Delete Your Data / 데이터 삭제 방법</h2>
              <div className="bg-dark-card rounded-lg p-4 border border-gray-700">
                <p className="mb-2"><strong>To delete your test results:</strong></p>
                <ol className="list-decimal pl-5 space-y-1">
                  <li>Open your browser's Developer Tools (F12)</li>
                  <li>Go to Application → Local Storage</li>
                  <li>Delete all entries for this domain</li>
                </ol>
                <p className="mt-3"><strong>To opt-out of personalized ads:</strong></p>
                <p>
                  Visit <a href="https://www.google.com/settings/ads" target="_blank" rel="noopener noreferrer" className="text-purple-400 hover:text-purple-300">Google Ad Settings</a> or <a href="https://optout.aboutads.info" target="_blank" rel="noopener noreferrer" className="text-purple-400 hover:text-purple-300">aboutads.info</a>
                </p>
              </div>
            </section>

            {/* Contact */}
            <section>
              <h2 className="text-xl font-semibold text-white mb-3">13. Contact / 연락처</h2>
              <p>
                For privacy-related inquiries or to exercise your rights, please contact us through the website.
              </p>
              <p className="mt-2">
                개인정보 관련 문의나 권리 행사는 웹사이트를 통해 연락해 주시기 바랍니다.
              </p>
            </section>

          </div>
        </motion.div>
      </div>
    </div>
  )
}
