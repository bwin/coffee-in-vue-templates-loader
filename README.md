
# coffee-in-vue-templates-loader

| Use coffeescript in vue templates as attributes or interpolations.

For example to use with `pug`, put the following in `nuxt.config.coffee`:
```coffee
[...]
	build:
		extend: (config, ctx) ->
			config.module.rules.push
				test: /\.pug$/
				use: ['coffee-in-vue-templates-loader', 'pug-plain-loader']
```
