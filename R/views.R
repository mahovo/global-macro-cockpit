# views.R — dashboard tabs, laid out along the transmission chain (financial
# conditions -> credit/rates -> orders/cycle -> labor -> inflation -> ...), each
# tagged with its cockpit zone. Tabs gather registry series by `theme`.

VIEWS <- list(
  list(id = "recession", title = "Recession Watch",      zone = "Warning lights",       themes = c("recession_watch")),
  list(id = "conditions", title = "Conditions & Liquidity", zone = "Windscreen",         themes = c("financial_conditions", "liquidity")),
  list(id = "credit_rates", title = "Credit & Rates",     zone = "Windscreen",           themes = c("credit", "rates")),
  list(id = "inflation",  title = "Inflation",             zone = "Windscreen / Weather", themes = c("inflation")),
  list(id = "cycle",      title = "Cycle & Growth",        zone = "Windscreen / GPS",     themes = c("cycle")),
  list(id = "labor",      title = "Labor",                 zone = "Windscreen",           themes = c("labor")),
  list(id = "trade_energy", title = "Trade & Commodities", zone = "Mirrors / Windscreen", themes = c("trade", "energy", "commodities")),
  list(id = "consumer",   title = "Consumer & Housing",    zone = "Mirrors",              themes = c("consumer", "housing")),
  list(id = "markets",    title = "Markets & Uncertainty", zone = "Side windows",         themes = c("markets", "uncertainty")),
  list(id = "china",      title = "China & Leaders",       zone = "Side windows",         themes = c("china", "leaders")),
  list(id = "bubbles",    title = "Bubbles / Froth",       zone = "Speedometer",          themes = c("bubbles"))
)

#' Registry series belonging to a view (by theme), in registry order.
view_series <- function(view, registry) {
  Filter(function(e) (e$theme %||% "") %in% view$themes, registry$series)
}
