import vibe.vibe;

import tailwind;

void main()
{
	Tailwind tailwind = new Tailwind;

	tailwind.input = "assets/app.css";
	tailwind.output = "public/styles.css";

	try {
		tailwind.run();
	} catch (TailwindException e) {
		logWarn("Tailwind watch can't be started. %s", e.message);
	}

	auto settings = new HTTPServerSettings;
	settings.port = 8080;
	settings.bindAddresses = ["::1", "127.0.0.1"];

	auto router = new URLRouter;
	router.get("/", &index);
	router.get("/login-form", &loginForm);
	router.get("/show-form", &showForm);
	router.get("*", serveStaticFiles("public"));

	auto listener = listenHTTP(settings, router);

	scope (exit)
	{
		listener.stopListening();
	}

	logInfo("Please open http://127.0.0.1:8080/ in your browser.");
	runApplication();
}

void index(HTTPServerRequest req, HTTPServerResponse res)
{
	res.render!("index.dt");
}

void loginForm(HTTPServerRequest req, HTTPServerResponse res)
{
	res.render!("login.dt");
}

void showForm(HTTPServerRequest req, HTTPServerResponse res)
{
	res.render!("form.dt");
}
