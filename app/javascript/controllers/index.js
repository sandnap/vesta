// Import and register all your controllers from the importmap under controllers/*

import { application } from "./application"

import ThemeController from "./theme_controller"
import ModalController from "./modal_controller"
import TransactionController from "./transaction_controller"
import NoteController from "./note_controller"
import ChartController from "./chart_controller"
import FormController from "./form_controller"
import PortfolioController from "./portfolio_controller"

// Eager load all controllers defined in the import map under controllers/**/*_controller
application.register("theme", ThemeController)
application.register("modal", ModalController)
application.register("transaction", TransactionController)
application.register("note", NoteController)
application.register("chart", ChartController)
application.register("form", FormController)
application.register("portfolio", PortfolioController)
