// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import { minidenticonSvg } from "minidenticons"

// minidenticons를 전역으로 사용 가능하게 설정
window.minidenticonSvg = minidenticonSvg
