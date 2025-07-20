import { Address, beginCell, Cell, Contract, contractAddress, ContractProvider, Sender, SendMode } from '@ton/core';

export type ContractMainConfig = {
    owner: Address;
    counter: bigint;
};

export function contractMainConfigToCell(config: ContractMainConfig): Cell {
    return beginCell().storeAddress(config.owner).storeUint(config.counter, 64).endCell();
}

export class ContractMain implements Contract {
    constructor(readonly address: Address, readonly init?: { code: Cell; data: Cell }) {}

    static createFromAddress(address: Address) {
        return new ContractMain(address);
    }

    static createFromConfig(config: ContractMainConfig, code: Cell, workchain = 0) {
        const data = contractMainConfigToCell(config);
        const init = { code, data };
        return new ContractMain(contractAddress(workchain, init), init);
    }

    async sendDeploy(provider: ContractProvider, via: Sender, value: bigint) {
        await provider.internal(via, {
            value,
            sendMode: SendMode.PAY_GAS_SEPARATELY,
            body: beginCell().endCell(),
        });
    }
}
