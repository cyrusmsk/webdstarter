import vibe.http.server;
import vibe.http.router;
import vibe.http.status;
import vibe.http.fileserver;

import vibe.core.log;
import vibe.core.core;

import tailwind;
import std;

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
	router
	    .get("/", &index)
		.get("/login-form", &loginForm)
		.get("/show-form", &showForm)
		.post("/submit-talk", &submitTalk);

	router.rebuild();
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
    bool isHTMX = req.headers.get("HX-Request", "") == "true" ? true : false;
    if (isHTMX)
        res.render!("index_dynamic.dt");
    else
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

void submitTalk(HTTPServerRequest req, HTTPServerResponse res)
{
    writeln(req.form);
    auto name = req.form.get("name");
    auto theme = req.form.get("theme");
    auto experience = req.form.get("experience");
    auto durationStr = req.form.get("duration");

    // Basic validation
    if (name.length == 0 || theme.length == 0 || experience.length == 0 || durationStr.length == 0) {
        res.statusCode = HTTPStatus.badRequest;
        res.writeBody("All fields are requried", "text/plain");
        return;
    }

    int duration;
    try {
        duration = to!int(durationStr);
    } catch (ConvException) {
        res.statusCode = HTTPStatus.badRequest;
        res.writeBody("Duration must be a number", "text/plain");
        return;
    }

    info("Received talk proposal: ", name, ", theme: ", theme, ", experience: ", experience, ", duration: ", duration);

    res.render!("form_finished.dt");
}
