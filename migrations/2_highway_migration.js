const Highway = artifacts.require("highway");
const Token = artifacts.require("RPDToken");

module.exports = async function (deployer) {
    await deployer.deploy(Token)
    await deployer.deploy(Highway, Token.address);
};
