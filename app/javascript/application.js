// Entry point for the build script in your package.json
// import "@hotwired/turbo-rails"
import "./controllers";
import { minidenticonSvg } from "minidenticons";

// minidenticons를 전역으로 사용 가능하게 설정
window.minidenticonSvg = minidenticonSvg;
