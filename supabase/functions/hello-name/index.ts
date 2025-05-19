// Setup type definitions for built-in Supabase Runtime APIs
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
console.info("server started");
Deno.serve(async (req) => {
  const { name } = await req.json();

  // Add artificial delay to simulate loading
  await new Promise((resolve) => setTimeout(resolve, 3000));

  const data = {
    message: `Hello ${name}! You are using the edge function!`,
  };
  return new Response(JSON.stringify(data), {
    headers: {
      "Content-Type": "application/json",
      "Connection": "keep-alive",
    },
  });
});
