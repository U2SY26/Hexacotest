import { Link } from 'react-router-dom'

export default function Footer() {
  const currentYear = new Date().getFullYear()

  return (
    <footer className="bg-dark-card border-t border-gray-800 py-8 mt-auto">
      <div className="max-w-6xl mx-auto px-4">
        {/* Business Info */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6 pb-6 border-b border-gray-800">
          <div className="text-center md:text-left">
            <h3 className="text-white font-semibold mb-3">사업자 정보</h3>
            <div className="text-gray-500 text-sm space-y-1">
              <p><span className="text-gray-400">상호:</span> U2DIA</p>
              <p><span className="text-gray-400">대표:</span> 최유이</p>
              <p><span className="text-gray-400">사업자등록번호:</span> 749-58-00902</p>
            </div>
          </div>
          <div className="text-center md:text-left">
            <h3 className="text-white font-semibold mb-3">소재지</h3>
            <div className="text-gray-500 text-sm">
              <p>인천광역시 서구 완정로 179, 6층 601-792호</p>
              <p>(왕길동, 제이원검단메디컬프라자)</p>
            </div>
          </div>
        </div>

        <div className="flex flex-col md:flex-row justify-between items-center gap-4">
          {/* Copyright */}
          <div className="text-gray-500 text-sm">
            © {currentYear} HEXACO Personality Test. All rights reserved.
          </div>

          {/* Links */}
          <div className="flex flex-wrap justify-center gap-4 text-sm">
            <Link
              to="/privacy"
              className="text-gray-400 hover:text-white transition-colors"
            >
              Privacy Policy
            </Link>
            <span className="text-gray-600">|</span>
            <Link
              to="/privacy"
              className="text-gray-400 hover:text-white transition-colors"
            >
              개인정보처리방침
            </Link>
            <span className="text-gray-600">|</span>
            <a
              href="https://www.google.com/settings/ads"
              target="_blank"
              rel="noopener noreferrer"
              className="text-gray-400 hover:text-white transition-colors"
            >
              Ad Settings
            </a>
          </div>

          {/* GDPR Notice */}
          <div className="text-gray-600 text-xs text-center md:text-right">
            GDPR & CCPA Compliant
          </div>
        </div>

        {/* Additional Legal Notice */}
        <div className="mt-4 pt-4 border-t border-gray-800 text-center text-xs text-gray-600">
          This website uses cookies for analytics and advertising. By using this site, you agree to our Privacy Policy.
        </div>
      </div>
    </footer>
  )
}
