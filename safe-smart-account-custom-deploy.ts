import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { getDeployerAccount } from "../utils/deploy";

const sleep = (ms: number): Promise<void> => new Promise((resolve) => setTimeout(resolve, ms));

const deploy: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments } = hre;
  const deployerAccount = await getDeployerAccount(hre);
  const { deploy } = deployments;

  await deploy("SimulateTxAccessor", {
    from: deployerAccount,
    args: [],
    log: true,
    deterministicDeployment: false,
  });
  await sleep(5000);

  await deploy("SafeProxyFactory", {
    from: deployerAccount,
    args: [],
    log: true,
    deterministicDeployment: false,
  });
  await sleep(5000);

  await deploy("TokenCallbackHandler", {
    from: deployerAccount,
    args: [],
    log: true,
    deterministicDeployment: false,
  });
  await sleep(5000);

  await deploy("CompatibilityFallbackHandler", {
    from: deployerAccount,
    args: [],
    log: true,
    deterministicDeployment: false,
  });
  await sleep(5000);

  await deploy("CreateCall", {
    from: deployerAccount,
    args: [],
    log: true,
    deterministicDeployment: false,
  });
  await sleep(5000);

  await deploy("MultiSend", {
    from: deployerAccount,
    args: [],
    log: true,
    deterministicDeployment: false,
  });
  await sleep(5000);

  await deploy("MultiSendCallOnly", {
    from: deployerAccount,
    args: [],
    log: true,
    deterministicDeployment: false,
  });
  await sleep(5000);

  await deploy("SignMessageLib", {
    from: deployerAccount,
    args: [],
    log: true,
    deterministicDeployment: false,
  });
  await sleep(5000);

  await deploy("SafeToL2Setup", {
    from: deployerAccount,
    args: [],
    log: true,
    deterministicDeployment: false,
  });
  await sleep(5000);

  await deploy("SafeL2", {
    from: deployerAccount,
    args: [],
    log: true,
    deterministicDeployment: false,
  });
  await sleep(5000);

  await deploy("Safe", {
    from: deployerAccount,
    args: [],
    log: true,
    deterministicDeployment: false,
  });
};

deploy.tags = ["factory", "handlers", "libraries", "singleton", "l2", "accessors", "l2-suite", "main-suite"];

export default deploy;
