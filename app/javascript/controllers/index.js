// Import and register all your controllers
import { application } from "./application"

// Import all controllers
import AccountController from "./account_controller"
import AuthorizationController from "./authorization_controller"
import GlobalController from "./global_controller"
import MembersController from "./members_controller"
import SearchController from "./search_controller"

// Register controllers
application.register("account", AccountController)
application.register("authorization", AuthorizationController)
application.register("global", GlobalController)
application.register("members", MembersController)
application.register("search", SearchController)
