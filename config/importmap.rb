# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
# 에디터는 TinyMCE를 쓰므로 Trix/Action Text JS는 pin하지 않는다.
# 서버 측 has_rich_text 는 그대로 동작한다.
pin "init"
