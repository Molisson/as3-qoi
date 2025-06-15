
async function getApp( request: Request ): Promise<Response> {
    const requestURL: string = new URL( request.url ).pathname;

    console.log( requestURL );

    if ( requestURL === "/crossdomain.xml" ) {
        return new Response( `<?xml version="1.0" encoding="UTF-8"?>
<cross-domain-policy>
	<allow-access-from domain="*" />
</cross-domain-policy>`, { headers: {
    "content-type": "text/xml; charset=utf-8"
} } );
    };

    if ( requestURL === "/sample.qoi" ) {
        return new Response( await Deno.readFile( "./sample.qoi" ), { headers: { "content-type": "image/qoi" } } );
    }

    return new Response( undefined, { status: 403 } );
};

Deno.serve(
    {
        port: 3000
    },
    getApp );

export {};