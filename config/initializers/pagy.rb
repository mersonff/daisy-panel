# frozen_string_literal: true

require "pagy/extras/bootstrap"
require "pagy/extras/overflow"

# Pagy global configuration
Pagy::DEFAULT[:items] = 10          # Items per page
Pagy::DEFAULT[:size] = 7            # Number of page links to show
Pagy::DEFAULT[:overflow] = :last_page
