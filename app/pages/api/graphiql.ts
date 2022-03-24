import { renderGraphiQL } from "@graphql-yoga/render-graphiql";
import { NextApiRequest, NextApiResponse } from "next";

export const config = {
  api: {
    bodyParser: false,
    externalResolver: true,
  },
};

export default async (req: NextApiRequest, res: NextApiResponse) => {
  res.status(200).end(
    renderGraphiQL({
      endpoint: process.env.NEXT_PUBLIC_SUPABASE_URL + "/rest/v1/rpc/graphql",
      headers: JSON.stringify({
        apikey: process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
      }),
    })
  );
};
