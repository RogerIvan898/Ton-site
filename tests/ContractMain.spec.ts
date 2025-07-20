import { Blockchain, SandboxContract, TreasuryContract } from '@ton/sandbox';
import { Cell, toNano } from '@ton/core';
import { ContractMain } from '../wrappers/ContractMain';
import '@ton/test-utils';
import { compile } from '@ton/blueprint';

describe('ContractMain', () => {
    let code: Cell;

    beforeAll(async () => {
        code = await compile('ContractMain');
    });

    let blockchain: Blockchain;
    let deployer: SandboxContract<TreasuryContract>;
    let contractMain: SandboxContract<ContractMain>;

    beforeEach(async () => {
        blockchain = await Blockchain.create();

        contractMain = blockchain.openContract(ContractMain.createFromConfig({}, code));

        deployer = await blockchain.treasury('deployer');

        const deployResult = await contractMain.sendDeploy(deployer.getSender(), toNano('0.05'));

        expect(deployResult.transactions).toHaveTransaction({
            from: deployer.address,
            to: contractMain.address,
            deploy: true,
            success: true,
        });
    });

    it('should deploy', async () => {
        // the check is done inside beforeEach
        // blockchain and contractMain are ready to use
    });
});
