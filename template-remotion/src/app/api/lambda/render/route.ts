import {
  AwsRegion,
  renderMediaOnLambda,
  RenderMediaOnLambdaOutput,
  speculateFunctionName,
} from "@remotion/lambda/client";
import { getOrCreateBucket } from "@remotion/lambda";
import {
  DISK,
  RAM,
  REGION,
  SITE_NAME,
  TIMEOUT,
} from "../../../../../config.mjs";
import { COMP_NAME } from "../../../../../types/constants";
import { RenderRequest } from "../../../../../types/schema";
import { executeApi } from "../../../../helpers/api-response";

export const POST = executeApi<RenderMediaOnLambdaOutput, typeof RenderRequest>(
  RenderRequest,
  async (req, body) => {
    if (
      !process.env.AWS_ACCESS_KEY_ID &&
      !process.env.REMOTION_AWS_ACCESS_KEY_ID
    ) {
      throw new TypeError(
        "Set up Remotion Lambda to render videos. See the README.md for how to do so.",
      );
    }
    if (
      !process.env.AWS_SECRET_ACCESS_KEY &&
      !process.env.REMOTION_AWS_SECRET_ACCESS_KEY
    ) {
      throw new TypeError(
        "The environment variable REMOTION_AWS_SECRET_ACCESS_KEY is missing. Add it to your .env file.",
      );
    }

    console.log("[Render API] Fetching default Remotion bucket...");
    const { bucketName } = await getOrCreateBucket({ region: REGION as AwsRegion });
    console.log(`[Render API] Bucket: ${bucketName}`);

    console.log("[Render API] Speculating function name...");
    const functionName = speculateFunctionName({
      diskSizeInMb: DISK,
      memorySizeInMb: RAM,
      timeoutInSeconds: TIMEOUT,
    });
    console.log(`[Render API] Function name: ${functionName}`);
    console.log("[Render API] Calling renderMediaOnLambda...");
    const startTime = Date.now();

    const fullServeUrl = `https://${bucketName}.s3.${REGION}.amazonaws.com/sites/${SITE_NAME}/index.html`;
    console.log(`[Render API] Serve URL: ${fullServeUrl}`);

    const result = await renderMediaOnLambda({
      codec: "h264",
      functionName,
      region: REGION as AwsRegion,
      serveUrl: fullServeUrl,
      forceBucketName: bucketName,
      composition: COMP_NAME,
      inputProps: body.inputProps,
      framesPerLambda: 60,
      downloadBehavior: {
        type: "download",
        fileName: "video.mp4",
      },
    });

    console.log(`[Render API] renderMediaOnLambda finished in ${Date.now() - startTime}ms`);
    return result;
  },
);
