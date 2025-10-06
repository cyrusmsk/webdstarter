import vibe.vibe;

import tailwind;

void main()
{
	Tailwind tailwind = new Tailwind;

	tailwind.input = "assets/app.css";
	tailwind.output = "public/styles/app.css";

	try {
		tailwind.run();
	} catch (TailwindException e) {
		logWarn("Tailwind watch can't be started. %s", e.message);
	}

	auto settings = new HTTPServerSettings;
	settings.port = 8080;
	settings.bindAddresses = ["::1", "127.0.0.1"];

	auto router = new URLRouter;
	router.get("/", &hello);
	router.get("*", serveStaticFiles("public"));

	auto listener = listenHTTP(settings, router);

	scope (exit)
	{
		listener.stopListening();
	}

	logInfo("Please open http://127.0.0.1:8080/ in your browser.");
	runApplication();
}

void hello(HTTPServerRequest req, HTTPServerResponse res)
{
	res.render!("index.dt");
}
