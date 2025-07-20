import { Address, toNano } from '@ton/core';
import { ContractMain } from '../wrappers/ContractMain';
import { compile, NetworkProvider } from '@ton/blueprint';

export async function run(provider: NetworkProvider) {
    const contractMain = provider.open(ContractMain.createFromConfig({
        owner: provider.sender().address as Address,
        counter: 0n
    }, await compile('ContractMain')));

    await contractMain.sendDeploy(provider.sender(), toNano('0.05'));

    await provider.waitForDeploy(contractMain.address);

    // run methods on `contractMain`
}
