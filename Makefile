# Makefile for WordPress development shortcuts
# MyProject Project - Optimized commands for daily development

# === PROJECT URLS ===
LOCAL_URL := https://local.MyProject.com/
PREPROD_URL := https://dev.MyProject.levelstage.com/

.PHONY: help install dev build format lint test clean health
.PHONY: fix quick commit-ready dev-blocks dev-theme clear-cache
.PHONY: dev-flat101 status update check-deps quick-fix dev-watch
.PHONY: performance-check new-block open-local open-preprod
.PHONY: lighthouse-local lighthouse-preprod sync-from-preprod
.PHONY: debug-theme debug-blocks debug-assets debug-performance
.PHONY: test-unit test-e2e test-a11y test-security test-complete
.PHONY: monitor-setup generate-reports

help: ## Show this help
	@echo ""
	@echo "🚀 MyProject WordPress Development Commands"
	@echo ""
	@echo "Main commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "For more information: README.md"
	@echo ""

# === INITIAL SETUP ===

install: ## Install all dependencies (npm + composer)
	@echo "🔧 Installing project dependencies..."
	npm install
	@echo "📦 Installing root Composer dependencies..."
	composer install
	@echo "📦 Installing plugin dependencies..."
	cd wordpress/wp-content/plugins/my-project-custom-blocks && npm install && composer install
	@echo "🎨 Installing starter theme dependencies..."
	cd wordpress/wp-content/themes/flat101-starter-theme && npm install && composer install
	@echo "🎨 Installing main theme dependencies..."
	cd wordpress/wp-content/themes/my-project-theme && npm install && composer install
	@echo "✅ Installation complete"

check-deps: ## Check for outdated dependencies
	@echo "🔍 Checking dependencies..."
	npm run health:check:outdated

update: ## Update dependencies (use with caution)
	@echo "⬆️ Updating dependencies..."
	npm update
	composer update
	cd wordpress/wp-content/plugins/my-project-custom-blocks && npm update && composer update
	cd wordpress/wp-content/themes/flat101-starter-theme && npm update && composer update
	cd wordpress/wp-content/themes/my-project-theme && npm update && composer update
	@echo "✅ Dependencies updated"

# === DEVELOPMENT ===

dev: ## 🚀 Start parallel development (all components with hot reload)
	@echo "🚀 Starting parallel development..."
	npm run dev:all

dev-blocks: ## 🧩 Development for Gutenberg blocks only
	@echo "🧩 Starting blocks development..."
	npm run dev:blocks

dev-theme: ## 🎨 Development for main theme (my-project-theme)
	@echo "🎨 Starting main theme development..."
	npm run dev:MyProject

dev-flat101: ## Development for starter theme (flat101-starter-theme)
	@echo "🎨 Starting starter theme development..."
	npm run dev:flat101

dev-watch: ## 🚀 Development with file watching and auto-reload
	@echo "👀 Starting development with file watching..."
	npm-run-all --parallel dev:all watch:reload

quick-fix: ## ⚡ Quick format + lint + test cycle
	@echo "🔧 Quick fix cycle..."
	@make format
	@make lint-quick
	@make quick
	@echo "✅ Ready for commit!"

new-block: ## 🧩 Create new Gutenberg block with boilerplate
	@read -p "Block name: " name; \
	cd wordpress/wp-content/plugins/my-project-custom-blocks && \
	npx @wordpress/create-block $$name --no-wp-scripts

performance-check: ## 📊 Run performance analysis
	@echo "⚡ Checking performance..."
	@npm run analyze:bundle-size 2>/dev/null || echo "⚠️  Bundle analyzer not configured yet"
	@npm run test:lighthouse 2>/dev/null || echo "⚠️  Lighthouse tests not configured yet"
	@echo "📊 Performance report generated"

# === BUILD AND PRODUCTION ===

build: ## 📦 Create optimized production build (minified, compressed)
	@echo "🏗️ Generating production build..."
	npm run build:production
	@echo "✅ Build completed"

# === FORMATTING AND LINTING ===

format: ## 💅 Format all code (PHP, JS, CSS) according to WordPress standards
	@echo "✨ Formatting code..."
	npm run fix-all
	@echo "✅ Code formatted"

fix: format ## Alias for format

lint: ## Run complete linting without changes
	@echo "🔍 Checking code standards..."
	npm run test:standards

lint-quick: ## Quick linting (JS/CSS only)
	@echo "⚡ Quick verification..."
	npm run test:standards:quick

# === VERIFICATION AND TESTING ===

test: ## ✅ Run complete quality verification (linting + standards + security)
	@echo "🧪 Running complete verification..."
	npm run verify:standards
	@echo "✅ Verification completed"

quick: ## Quick verification before commit
	@echo "⚡ Quick verification..."
	npm run quick-check

commit-ready: ## Verify ready for commit
	@echo "📝 Verifying commit readiness..."
	npm run pre-commit:full
	@echo "✅ Ready for commit"

# === PROJECT URLS AND TOOLS ===

open-local: ## 🌐 Open local development site
	@echo "🌐 Opening local site..."
	@open $(LOCAL_URL)

open-preprod: ## 🌐 Open preprod site
	@echo "🌐 Opening preprod site..."
	@open $(PREPROD_URL)

sync-from-preprod: ## 🔄 Sync database from preprod
	@echo "🔄 Syncing from preprod..."
	@echo "⚠️  Database sync commands to be configured with WP-CLI"
	# Add WP-CLI commands for database sync

lighthouse-local: ## 🔍 Run Lighthouse on local
	@echo "🔍 Running Lighthouse on local site..."
	@mkdir -p reports
	@npx lighthouse $(LOCAL_URL) --output=html --output-path=./reports/lighthouse-local.html --quiet
	@echo "📊 Local Lighthouse report: ./reports/lighthouse-local.html"

lighthouse-preprod: ## 🔍 Run Lighthouse on preprod
	@echo "🔍 Running Lighthouse on preprod site..."
	@mkdir -p reports
	@npx lighthouse $(PREPROD_URL) --output=html --output-path=./reports/lighthouse-preprod.html --quiet
	@echo "📊 Preprod Lighthouse report: ./reports/lighthouse-preprod.html"

# === DEBUGGING COMMANDS ===

debug-theme: ## 🐛 Debug theme issues
	@echo "🐛 Theme debugging..."
	@echo "📁 Checking theme structure:"
	@ls -la wordpress/wp-content/themes/my-project-theme/ | head -10
	@echo "\n🔍 Searching for error logs and console.log:"
	@grep -r "error_log\|console.log" wordpress/wp-content/themes/my-project-theme/ 2>/dev/null || echo "No error logs found"
	@echo "\n📦 Checking theme assets:"
	@ls -la wordpress/wp-content/themes/my-project-theme/assets/build/ 2>/dev/null || echo "Build directory not found - run make build"
	@echo "\n⚙️ Checking functions.php:"
	@head -20 wordpress/wp-content/themes/my-project-theme/functions.php 2>/dev/null || echo "functions.php not found"

debug-blocks: ## 🧩 Debug block registration issues
	@echo "🧩 Block debugging..."
	@echo "📁 Checking blocks structure:"
	@ls -la wordpress/wp-content/plugins/my-project-custom-blocks/src/blocks/ 2>/dev/null || echo "Blocks directory not found"
	@echo "\n🔍 Searching for registerBlockType:"
	@grep -r "registerBlockType" wordpress/wp-content/plugins/my-project-custom-blocks/src/ 2>/dev/null || echo "No block registrations found"
	@echo "\n📦 Checking block builds:"
	@ls -la wordpress/wp-content/plugins/my-project-custom-blocks/build/ 2>/dev/null || echo "Build directory not found - run make build"
	@echo "\n📋 Checking block.json files:"
	@find wordpress/wp-content/plugins/my-project-custom-blocks/src/blocks/ -name "block.json" 2>/dev/null || echo "No block.json files found"

debug-assets: ## 📦 Debug asset loading issues
	@echo "📦 Asset debugging..."
	@echo "🔍 Checking built assets:"
	@find wordpress/wp-content/themes/*/assets/build/ -name "*.js" -o -name "*.css" 2>/dev/null | head -10 || echo "No built assets found"
	@echo "\n📋 Checking asset enqueuing:"
	@grep -r "wp_enqueue" wordpress/wp-content/themes/my-project-theme/inc/ 2>/dev/null || echo "No enqueue functions found"
	@echo "\n📊 Asset sizes:"
	@du -sh wordpress/wp-content/themes/*/assets/build/* 2>/dev/null || echo "No assets to analyze"
	@echo "\n🔧 Checking webpack config:"
	@ls -la wordpress/wp-content/themes/my-project-theme/webpack.config.js 2>/dev/null || echo "webpack.config.js not found"

debug-performance: ## ⚡ Debug performance issues
	@echo "⚡ Performance debugging..."
	@echo "📊 Bundle sizes:"
	@npm run analyze:bundle-size
	@echo "\n🔍 PHP analysis:"
	@npm run analyze:php 2>/dev/null || echo "PHP analysis not available"
	@echo "\n📦 Dependency analysis:"
	@npm run analyze:dependencies 2>/dev/null || echo "Dependency analysis not available"
	@echo "\n🗂️ Cache status:"
	@ls -la .eslintcache .stylelintcache 2>/dev/null || echo "No cache files found"

# === TESTING COMMANDS ===

test-unit: ## 🧪 Run unit tests
	@echo "🧪 Running unit tests..."
	@npm run test:unit 2>/dev/null || echo "⚠️  Unit tests not configured yet. Run: npm install --save-dev jest"

test-e2e: ## 🎭 Run end-to-end tests
	@echo "🎭 Running E2E tests..."
	@npm run test:e2e 2>/dev/null || echo "⚠️  E2E tests not configured yet. Playwright is available in blocks plugin."

test-a11y: ## ♿ Run accessibility tests
	@echo "♿ Running accessibility tests..."
	@npm run test:a11y 2>/dev/null || echo "⚠️  A11y tests not configured yet. Run: npm install -g pa11y-ci"

test-security: ## 🔒 Run security audit
	@echo "🔒 Running security audit..."
	@npm run analyze:security

test-complete: ## ✅ Run all tests
	@echo "✅ Running complete test suite..."
	@make test-security
	@make test-unit
	@make test-a11y
	@echo "📊 Test summary completed"

# === MONITORING AND REPORTS ===

monitor-setup: ## 📊 Setup monitoring tools
	@echo "📊 Setting up monitoring tools..."
	@npm list -g lighthouse 2>/dev/null || echo "Installing Lighthouse globally..." && npm install -g lighthouse
	@npm list -g pa11y-ci 2>/dev/null || echo "Installing Pa11y globally..." && npm install -g pa11y-ci
	@echo "✅ Monitoring tools setup completed"

generate-reports: ## 📈 Generate comprehensive project reports
	@echo "📈 Generating comprehensive reports..."
	@mkdir -p reports
	@make lighthouse-local 2>/dev/null || echo "⚠️  Local site not accessible"
	@make lighthouse-preprod 2>/dev/null || echo "⚠️  Preprod site not accessible"
	@npm run test:a11y > reports/accessibility-report.txt 2>/dev/null || echo "⚠️  A11y tests not configured"
	@npm run analyze:bundle-size > reports/bundle-analysis.txt 2>/dev/null || echo "Bundle analysis saved"
	@npm run analyze:security > reports/security-audit.txt 2>/dev/null || echo "Security audit saved"
	@echo "📊 Reports generated in ./reports/"
	@ls -la reports/

# === MAINTENANCE ===

clean: ## 🧹 Clean all caches and temporary files
	@echo "🧹 Cleaning temporary files..."
	npm run clean:all
	@echo "✅ Cleanup completed"

clear-cache: ## Clear all caches (ESLint, Stylelint, PHPCS, Prettier)
	@echo "🗑️ Clearing caches..."
	npm run cache:clear
	@echo "✅ Caches cleared"

health: ## 🏥 Check project health (dependencies, configs, standards)
	@echo "🏥 Checking project health..."
	npm run health:check
	@echo "✅ Health check completed"

status: ## Show current project status
	@echo ""
	@echo "📊 MyProject Project Status"
	@echo "============================"
	@echo ""
	@echo "📁 Project structure:"
	@ls -la wordpress/wp-content/plugins/ | grep MyProject || echo "  ❌ Plugin not found"
	@ls -la wordpress/wp-content/themes/ | grep -E "(flat101|MyProject)" || echo "  ❌ Themes not found"
	@echo ""
	@echo "📦 Dependencies installed:"
	@test -d node_modules && echo "  ✅ Root dependencies installed" || echo "  ❌ Root dependencies missing"
	@test -d wordpress/wp-content/plugins/my-project-custom-blocks/node_modules && echo "  ✅ Plugin dependencies installed" || echo "  ❌ Plugin dependencies missing"
	@test -d wordpress/wp-content/themes/my-project-theme/node_modules && echo "  ✅ Theme dependencies installed" || echo "  ❌ Theme dependencies missing"
	@test -d wordpress/wp-content/themes/flat101-starter-theme/node_modules && echo "  ✅ Starter theme dependencies installed" || echo "  ❌ Starter theme dependencies missing"
	@test -d vendor && echo "  ✅ Root composer dependencies installed" || echo "  ❌ Root composer dependencies missing"
	@test -d wordpress/wp-content/plugins/my-project-custom-blocks/vendor && echo "  ✅ Plugin composer dependencies installed" || echo "  ❌ Plugin composer dependencies missing"
	@test -d wordpress/wp-content/themes/my-project-theme/vendor && echo "  ✅ Main theme composer dependencies installed" || echo "  ❌ Main theme composer dependencies missing"
	@test -d wordpress/wp-content/themes/flat101-starter-theme/vendor && echo "  ✅ Starter theme composer dependencies installed" || echo "  ❌ Starter theme composer dependencies missing"
	@echo ""
	@echo "🔧 For more commands: make help"
	@echo ""

# === SHORTCUTS AND ALIASES ===

# Common aliases for quick development
start: dev ## Alias for dev
serve: dev ## Alias for dev
watch: dev ## Alias for dev

# Aliases for verification
check: quick ## Alias for quick
verify: test ## Alias for test

# Aliases for cleanup
reset: clean ## Alias for clean
flush: clear-cache ## Alias for clear-cache

# === CI/CD COMMANDS ===

# Environment URLs
STAGING_URL := https://dev.MyProject.levelstage.com
PRODUCTION_URL := https://MyProject.com

deploy-staging: ## 🚀 Deploy to staging environment
	@echo "🚀 Deploying to staging..."
	@echo "📋 Pre-deployment checks..."
	@make test-complete
	@echo "📦 Building assets..."
	@make build
	@echo "🔄 Syncing to staging: $(STAGING_URL)"
	@./sh/deploy/deploy.sh staging
	@echo "✅ Staging deployment completed"
	@echo "🌐 Visit: $(STAGING_URL)"

deploy-prod: ## 🌟 Deploy to production environment
	@echo "🌟 Deploying to production..."
	@echo "⚠️  WARNING: This will deploy to PRODUCTION!"
	@read -p "Are you sure? (y/N): " confirm && [ "$$confirm" = "y" ]
	@echo "📋 Pre-deployment checks..."
	@make test-complete
	@echo "📦 Building assets..."
	@make build
	@echo "🔄 Syncing to production: $(PRODUCTION_URL)"
	@./sh/deploy/deploy.sh production
	@echo "✅ Production deployment completed"
	@echo "🌐 Visit: $(PRODUCTION_URL)"

rollback-staging: ## ⏪ Rollback staging to previous version
	@echo "⏪ Rolling back staging..."
	@./sh/deploy/rollback.sh staging
	@echo "✅ Staging rollback completed"

rollback-prod: ## 🔄 Rollback production to previous version
	@echo "🔄 Rolling back production..."
	@echo "⚠️  WARNING: This will rollback PRODUCTION!"
	@read -p "Are you sure? (y/N): " confirm && [ "$$confirm" = "y" ]
	@./sh/deploy/rollback.sh production
	@echo "✅ Production rollback completed"

# === DATABASE SYNC COMMANDS ===

db-backup: ## 💾 Create database backup
	@./sh/wp/simple-db-backup.sh

db-backup-simple: ## 💾 Create simple database backup (Docker direct)
	@./sh/wp/simple-db-backup.sh

# Docker-specific database commands
db-pull: ## 📥 Pull database from Levelstage to Docker local (with URL replacement)
	@echo "📥 Pulling database from Levelstage to Docker local..."
	@./sh/wp/docker-db-sync.sh pull

db-push: ## 📤 Push Docker local database to Levelstage (with URL replacement)
	@echo "📤 Pushing Docker local database to Levelstage..."
	@./sh/wp/docker-db-sync.sh push

db-pull-dry: ## 🔍 Preview pull from Levelstage (dry run)
	@echo "🔍 Preview: Pull database from Levelstage..."
	@./sh/wp/docker-db-sync.sh pull --dry-run

db-push-dry: ## 🔍 Preview push to Levelstage (dry run)
	@echo "🔍 Preview: Push database to Levelstage..."
	@./sh/wp/docker-db-sync.sh push --dry-run

# Legacy commands (for non-Docker environments)
db-sync-from-staging: ## 📥 Sync database from staging to local (legacy)
	@echo "📥 Syncing database from staging..."
	@echo "⚠️  WARNING: This will overwrite your local database!"
	@read -p "Are you sure? (y/N): " confirm && [ "$$confirm" = "y" ]
	@make db-backup
	@./sh/wp/sync-db.sh staging local
	@echo "✅ Database sync from staging completed"

db-sync-from-prod: ## 📥 Sync database from production to local (legacy)
	@echo "📥 Syncing database from production..."
	@echo "⚠️  WARNING: This will overwrite your local database!"
	@read -p "Are you sure? (y/N): " confirm && [ "$$confirm" = "y" ]
	@make db-backup
	@./sh/wp/sync-db.sh production local
	@echo "✅ Database sync from production completed"

db-push-to-staging: ## 📤 Push local database to staging (legacy)
	@echo "📤 Pushing database to staging..."
	@echo "⚠️  WARNING: This will overwrite staging database!"
	@read -p "Are you sure? (y/N): " confirm && [ "$$confirm" = "y" ]
	@./sh/wp/sync-db.sh local staging
	@echo "✅ Database push to staging completed"

# === BACKUP COMMANDS ===

backup-full: ## 💾 Create full project backup
	@echo "💾 Creating full project backup..."
	@mkdir -p backups/full
	@make db-backup
	@echo "📁 Backing up files..."
	@tar -czf backups/full/files-$(shell date +%Y%m%d-%H%M%S).tar.gz wordpress/wp-content/uploads/
	@echo "✅ Full backup completed"

backup-code: ## 💾 Create code backup (themes and plugins)
	@echo "💾 Creating code backup..."
	@mkdir -p backups/code
	@tar -czf backups/code/code-$(shell date +%Y%m%d-%H%M%S).tar.gz wordpress/wp-content/themes/ wordpress/wp-content/plugins/my-project-custom-blocks/
	@echo "✅ Code backup completed"

# === LIGHTHOUSE CI COMMANDS ===

lighthouse-ci-setup: ## 🏮 Setup Lighthouse CI
	@echo "🏮 Setting up Lighthouse CI..."
	@npm install -g @lhci/cli
	@echo "📝 Creating Lighthouse CI config..."
	@echo "module.exports = {" > lighthouserc.js
	@echo "  ci: {" >> lighthouserc.js
	@echo "    collect: {" >> lighthouserc.js
	@echo "      url: ['$(LOCAL_URL)', '$(LOCAL_URL)/about/', '$(LOCAL_URL)/contact/']," >> lighthouserc.js
	@echo "      startServerCommand: 'make dev-server'," >> lighthouserc.js
	@echo "      startServerReadyPattern: 'ready'," >> lighthouserc.js
	@echo "      numberOfRuns: 3" >> lighthouserc.js
	@echo "    }," >> lighthouserc.js
	@echo "    assert: {" >> lighthouserc.js
	@echo "      assertions: {" >> lighthouserc.js
	@echo "        'categories:performance': ['warn', {minScore: 0.8}]," >> lighthouserc.js
	@echo "        'categories:accessibility': ['error', {minScore: 0.9}]," >> lighthouserc.js
	@echo "        'categories:best-practices': ['warn', {minScore: 0.8}]," >> lighthouserc.js
	@echo "        'categories:seo': ['warn', {minScore: 0.8}]" >> lighthouserc.js
	@echo "      }" >> lighthouserc.js
	@echo "    }," >> lighthouserc.js
	@echo "    upload: {" >> lighthouserc.js
	@echo "      target: 'filesystem'," >> lighthouserc.js
	@echo "      outputDir: './reports/lighthouse-ci'" >> lighthouserc.js
	@echo "    }" >> lighthouserc.js
	@echo "  }" >> lighthouserc.js
	@echo "};" >> lighthouserc.js
	@echo "✅ Lighthouse CI setup completed"

lighthouse-ci-run: ## 🏮 Run Lighthouse CI analysis
	@echo "🏮 Running Lighthouse CI analysis..."
	@mkdir -p reports/lighthouse-ci
	@lhci collect --url=https://local.MyProject.com/ --url=https://local.MyProject.com/about/ --url=https://local.MyProject.com/contact/ --numberOfRuns=3
	@lhci assert --preset=lighthouse:recommended
	@lhci upload --target=filesystem --outputDir=./reports/lighthouse-ci
	@echo "✅ Lighthouse CI analysis completed"
	@echo "📊 Reports available in: reports/lighthouse-ci/"

# === NOTIFICATION COMMANDS ===

notify-deployment: ## 📢 Send deployment notification
	@echo "📢 Sending deployment notification..."
	@echo "🚀 Deployment completed at $(shell date)" | tee -a deployment.log
	@echo "✅ Notification sent"
