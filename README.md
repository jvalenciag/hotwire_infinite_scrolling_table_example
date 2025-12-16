# Hotwire Infinite Scrolling Table - Sample App

This is a **Rails 8.1** application demonstrating **infinite scrolling** in a products table using **Hotwire (Turbo + Stimulus)** with **Pagy** for pagination.

## 🏗️ Tech Stack

| Component | Technology |
|-----------|------------|
| **Backend** | Rails 8.1, PostgreSQL |
| **Frontend** | Hotwire (Turbo + Stimulus), Tailwind CSS |
| **Pagination** | Pagy (`:countless` mode) |
| **Search** | pg_search with PostgreSQL full-text search (`tsvector`) |
| **Build** | Bun (JS bundling), Propshaft (assets) |

## 🔥 Hotwire Implementation

### 1. Turbo Frames for Lazy Loading

The infinite scroll is powered by **nested Turbo Frames** with `loading: :lazy`:

**Initial Frame** ([app/views/products/index.html.erb](app/views/products/index.html.erb)):
```erb
<%= turbo_frame_tag "products-table" do %>
  <!-- Table structure with sticky header -->
  <tbody id="products-table-body"></tbody>
  
  <%= turbo_frame_tag "products-table-body-pagination", 
      src: products_path(format: :turbo_stream, q: params[:q]), 
      loading: :lazy do %>
    <div>Loading...</div>
  <% end %>
<% end %>
```

**Key mechanism**: The `loading: :lazy` attribute delays fetching until the frame enters the viewport—this triggers the infinite scroll!

### 2. Turbo Stream for Appending Rows

When the lazy frame loads, the controller responds with `turbo_stream` format ([app/views/products/index.turbo_stream.erb](app/views/products/index.turbo_stream.erb)):

```erb
<%= turbo_stream.remove "products-table-body-pagination" %>
<%= turbo_stream.append "products-table-body" do %>
  <%= render partial: "product_row", collection: @products, ... %>
  <% if @pagy.next.present? %>
    <%= turbo_frame_tag "products-table-body-pagination", 
        src: products_path(page: @pagy.next, format: :turbo_stream, q: params[:q]), 
        loading: :lazy do %>
      <div>Loading...</div>
    <% end %>
  <% end %>
<% end %>
```

**The pattern**:
1. **Remove** the old pagination placeholder
2. **Append** new product rows to the table body
3. **Insert a new lazy-loading frame** pointing to the next page (if more pages exist)
4. When user scrolls to the new placeholder → repeat!

### 3. Stimulus for Debounced Search

The [app/javascript/controllers/products_search_controller.js](app/javascript/controllers/products_search_controller.js) provides real-time search with debouncing:

```javascript
import { Controller } from "@hotwired/stimulus"
import debounce from "debounce"

export default class extends Controller {
  initialize() {
    this.submit = debounce(this.submit.bind(this), 300)
  }

  submit() {
    this.element.requestSubmit()
  }
}
```

Connected to the search form via `data-controller="products-search"` and `data-action="input->products-search#submit"`, it auto-submits after 300ms of typing pause.

## 📦 Pagy Countless Pagination

The controller uses Pagy's `:countless` mode:

```ruby
@pagy, @products = pagy(:countless, query, items: 25)
```

**Why `:countless`?** It doesn't execute a `COUNT(*)` query—perfect for infinite scroll where you don't need total counts, just "is there a next page?"

## 🔍 Full-Text Search with pg_search

The Product model uses PostgreSQL's native `tsvector` columns:

```ruby
pg_search_scope :search_all,
  against: [:name, :description],
  associated_against: { brand: :searchable },
  using: {
    tsearch: {
      tsvector_column: "searchable",
      prefix: true,  # Enables partial matching
      highlight: { ... }
    }
  }
```

The database stores **generated `tsvector` columns** with weighted search terms:
```ruby
t.virtual "searchable", type: :tsvector, 
  as: "(setweight(to_tsvector('simple', name), 'A') || 
       setweight(to_tsvector('simple', description), 'B'))", 
  stored: true
```

## 🗂️ Data Models

| Model | Relationships |
|-------|--------------|
| **Product** | `belongs_to :brand`, has `name`, `description`, `sku`, `enabled` |
| **Brand** | `has_many :products`, has `name`, `short_name` |

## 🎨 UI Features

- **Sticky table header** — stays visible while scrolling through products
- **Search highlighting** — matched terms are highlighted using Rails' `highlight()` helper
- **Tailwind CSS** styling for a clean, responsive interface
- **Scrollable container** — `max-height: 50vh` with `overflow-y-auto`

## 📁 Key Files

| File | Purpose |
|------|---------|
| [app/views/products/index.html.erb](app/views/products/index.html.erb) | Main table with initial lazy Turbo Frame |
| [app/views/products/index.turbo_stream.erb](app/views/products/index.turbo_stream.erb) | Appends rows + inserts next lazy frame |
| [app/views/products/_product_row.html.erb](app/views/products/_product_row.html.erb) | Single table row partial |
| [app/controllers/products_controller.rb](app/controllers/products_controller.rb) | Handles HTML & Turbo Stream responses |
| [app/javascript/controllers/products_search_controller.js](app/javascript/controllers/products_search_controller.js) | Debounced search submission |

## ⚡ How the Infinite Scroll Works

```
User scrolls → Lazy frame enters viewport → 
Turbo fetches /products.turbo_stream?page=N → 
Server responds with turbo_stream actions →
  1. Remove old placeholder
  2. Append new rows to tbody
  3. Insert new lazy frame for next page →
User continues scrolling → Repeat!
```

This approach requires **zero custom JavaScript** for the infinite scroll itself—it's all declarative with Turbo Frames!

## 🚀 Setup

### Prerequisites

- Ruby 3.3+
- PostgreSQL
- Bun (for JavaScript dependencies)

### Installation

```bash
# Install dependencies
bundle install
bun install

# Setup database
bin/rails db:create db:migrate db:seed

# Start development server
bin/dev
```

Visit `http://localhost:3000/products` to see the infinite scrolling table in action!
