/*
    Auxiliary library for Tolk.

    A collection of helper functions for simplified development in the Tolk language.
    Contains commonly used utilities to reduce boilerplate and improve code readability.

    by SoftwareMaestro:
        - https://github.com/SoftwareMaestro16
        - https://t.me/SoftwareMaestro
*/

@pure
fun curLt(): int
    asm "LTIME";
@pure
fun now(): int
    asm "NOW";
@pure
fun myAddress(): address
    asm "MYADDR";
@pure
fun myAddressAsSlice(): slice
    asm "MYADDR";
@pure
fun blockLt(): int
    asm "BLOCKLT";
@pure
fun getContractData(): cell 
    asm "c4 PUSH";
@pure
fun setContractData(c: cell): cell
    asm "c4 POP";

@inline
fun packJettonWalletData(balance: int, ownerAddress: address, jettonMasterAddress: address, jettonWalletCode: cell): cell {
   return  beginCell()
            .storeCoins(balance)
            .storeAddress(ownerAddress)
            .storeAddress(jettonMasterAddress)
            .storeRef(jettonWalletCode)
           .endCell();
}

@inline
fun calculateJettonWalletStateInit(ownerAddress: address, jettonMasterAddress: address, jettonWalletCode: cell): cell {
  return beginCell()
          .storeUint(0, 2)
          .storeDict(jettonWalletCode)
          .storeDict(packJettonWalletData(0, ownerAddress, jettonMasterAddress, jettonWalletCode))
          .storeUint(0, 1)
         .endCell();
}

@inline
fun calculateJettonWalletAddress(stateInit: cell): address {
  var data = beginCell().storeUint(4, 3)
                     .storeInt(0, 8) // wc 0
                     .storeUint(stateInit.hash(), 256)
                     .endCell()
                     .beginParse();
    return data as address;
}

@inline
fun calculateUserJettonWalletAddress(ownerAddress: address, jettonMasterAddress: address, jettonWalletCode: cell): address {
  return calculateJettonWalletAddress(calculateJettonWalletStateInit(ownerAddress, jettonMasterAddress, jettonWalletCode));
}

/* CONSTS */

const CONST_MIN_RESERVE = 15000000;   // 0.015 TON 
const CONST_JETTON_TRANSFER = 55000000;   // 0.055 TON 
const CONST_BURN_JETTONS = 50000000;   // 0.05  TON 
const CONST_MIN_EXCESS = 10000000;   // 0.01  TON 
const CONST_DEPLOY = 50000000;   // 0.05  TON 
const CONST_MIN_TON_FOR_STORAGE = 50000000;   // 0.05  TON 

/* OP-CODES */

const OP_EXCESSES = 0xd53276db;
const OP_JETTON_TRANSFER = 0x0f8a7ea5;
const OP_TRANSFER_NOTIFICATION = 0x7362d09c;
const OP_PROVIDE_WALLET_ADDRESS = 0x2c76b973;
const OP_TAKE_WALLET_ADDRESS = 0xd1735400;
const OP_BURN_JETTON = 0x595f07bc;
const OP_SEND_ANY_MESSAGE = 0xa47d989c;
const OP_SET_CODE = 0xe2d2d211;
const OP_WITHDRAW_TON = 0x37726bdb;
const OP_WITHDRAW_JETTON = 0x11c09682;
const OP_DEACTIVATE_WALLET = 0x4b14c485;
const OP_NFT_TRANSFER = 0x5fcc3d14;
const OP_RECEIVED_NFT = 0x05138d91;
const OP_LOCK = 0x878f9b0e;
const OP_UNLOCK = 0x6ae4b0ef;
const OP_INCREMENT = 0x5588464e;
const OP_DECREMENT = 0xf9adbd4f;
const OP_DEDUST_SWAP_TO_JETTON = 0xea06185d;
const OP_DEDUST_SWAP_TO_TON = 0xe3a0d482;
const OP_DEDUST_PAYOUT = 0x474f86cf;

/* ERRORS */


// jetton

const ERR_INVALID_OP = 709
const ERR_NOT_FROM_ADMIN = 73
const ERR_UNAUTHORIZED_BURN = 74
const ERR_NOT_ENOUGH_AMOUNT_TO_RESPOND = 75
const ERR_NOT_FROM_OWNER = 705
const ERR_NOT_ENOUGH_TON = 709
const ERR_NOT_ENOUGH_GAS = 707
const ERR_INVALID_WALLET = 707
const ERR_WRONG_WORKCHAIN = 333
const ERR_NOT_ENOUGH_BALANCE = 706
const ERR_INVALID_PAYLOAD = 708

// nft

const ERROR_NOT_FROM_ADMIN = 401
const ERROR_NOT_FROM_OWNER = 401
const ERROR_NOT_FROM_COLLECTION = 405
const ERROR_BATCH_LIMIT_EXCEEDED = 399
const ERROR_INVALID_ITEM_INDEX = 402
const ERROR_INCORRECT_FORWARD_PAYLOAD = 708
const ERROR_INVALID_WORKCHAIN = 333
const ERROR_TOO_SMALL_REST_AMOUNT = 402

/* OTHER */

const BURN_ADDRESS = address("EQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAM9c");
const TESTNET_BURN_ADDRESS = address("0QAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACkT");
const TON_VAULT_ADDRESS_DEDUST = address("EQDa4VOnTYlLvDJ0gZjNYm5PXfSmmtL6Vs6A_CZEtXCNICq_"); // mainnet
const WORKCHAIN = 0;
const ONE_TON = 1000000000;
const FIVE_CENT_TON = 50000000; // 0.05 

/* FUNCTIONS */

@inline
fun toNano(amount: int): int {
    if (amount < 0) {
        throw 922; 
    }
    return amount * 1000000000;
}

@inline
fun fromNano(amount: int): int {
    if (amount < 0) {
        throw 922;
    }
    return amount / 1000000000;
}

@inline
fun getContractAddress(workchain: int, stateInit: cell): slice {
    return beginCell()
        .storeUint(4, 3)
        .storeInt(workchain, 8)
        .storeUint(stateInit.hash(), 256)
    .endCell().beginParse();
}

@inline
fun pow(n: int, e: int): int {
  if (e == 0) {
    return 1;
  }

  if (e == 1) {
    return n;
  }

  var p: int = pow(n, (e / 2));
  p = p * p;
    
  if ((e % 2) == 1) {
    p = p * n;
  }
    
  return p;
}

@inline
fun sqrt(x: int): int {
  if (x == 0) { return x; }

  var r: int = 181;
  var xx: int = x;
  if (xx >= 0x100000000000000000000000000000000) {
    xx >>= 128;
    r <<= 64;
  }
  if (xx >= 0x10000000000000000) {
    xx >>= 64;
    r <<= 32;
  }
  if (xx >= 0x100000000) {
    xx >>= 32;
    r <<= 16;
  }
  if (xx >= 0x10000) {
    xx >>= 16;
    r <<= 8;
  }

  r = (r * (xx + 65536)) >> 18;

  repeat(7) {
    r = (r + x / r) >> 1;
  }

  var r1: int = x / r;

  return (r < r1 ? r : r1);
}

@inline
fun avg(x: int, y: int): int {
  return (x + y) / 2;
}

@inline
fun exp(x: int): int {
  return (x >= 0 ? 1 << x : 1 >> (x * -1));
}

@pure
fun log2(x: int): int
    asm "UBITSIZE DEC";

@pure
fun mod(x: int, y: int): int
    asm "MOD";

@inline
fun randRange(a: int, b: int): int {
    random.initializeBy(curLt() + now());
    return random.range(b - a) + a;
}

/* MESSAGES */

@inline_ref
fun sendWithStateInit(amount: int, to: address, stateInit: cell, body: cell, mode: int) {
    var msg: cell = beginCell()
        .storeUint(0x18, 6)
        .storeAddress(to)
        .storeCoins(amount)
        .storeUint(7, 108)
        .storeRef(stateInit)
        .storeRef(body)
    .endCell();
    sendRawMessage(msg, mode);
}

@inline
fun transferTonComment(senderAddress: address, amount: int, comment: slice) {
    var msg = beginCell()
        .storeUint(0x10, 6)
        .storeAddress(senderAddress) 
        .storeCoins(amount)
        .storeUint(0, 107 + 32)
        .storeSlice(comment)
    .endCell();
    sendRawMessage(msg, 1);
}

@inline
fun transferTon(senderAddress: address, amount: int) {
    var msg = beginCell()
        .storeUint(0x10, 6)
        .storeAddress(senderAddress) 
        .storeCoins(amount)
        .storeUint(0, 107)
    .endCell();
    sendRawMessage(msg, 1);
}

@inline
fun withdrawAllTon(senderAddress: address) {
    var msg = beginCell()
        .storeUint(0x10, 6)
        .storeAddress(senderAddress)
        .storeCoins(0)
        .storeUint(0, 107)
    .endCell();
    sendRawMessage(msg, 128);
}

@inline
fun transferJettons(
    toJettonWallet: address,
    toAddress: address,
    jettonsAmount: int,
    tonsAmont: int,
    sendMode: int,
    queryId: int
) {
    var message: builder = 
        beginCell()
            .storeUint(0x18, 6)
            .storeAddress(toJettonWallet)
            .storeCoins(tonsAmont)
            .storeUint(0, 1 + 4 + 4 + 64 + 32 + 1 + 1)
            .storeUint(OP_JETTON_TRANSFER, 32)
            .storeUint(queryId, 64)
            .storeCoins(jettonsAmount)
            .storeAddress(toAddress)      // to_owner_address
            .storeUint(0, 2)              // response_address (empty)
            .storeInt(0, 1)               // custom_payload (empty)
            .storeCoins(0)                // forward amount
            .storeInt(0, 1);              // forward_payload (empty)
    
    sendRawMessage(message.endCell(), sendMode);
}

@inline
fun transferJettonsComment(
    toJettonWallet: address,
    toAddress: address,
    jettonsAmount: int,
    tonsAmont: int,
    sendMode: int,
    queryId: int,
    comment: slice
) {
    var forwardPayload: cell = beginCell()
        .storeUint(0, 32)           // Indicates the presence of a comment
        .storeSlice(comment)        // comment remains slice
    .endCell();

    var body: cell = beginCell()
        .storeUint(OP_JETTON_TRANSFER, 32)
        .storeUint(queryId, 64)
        .storeCoins(jettonsAmount)
        .storeAddress(toAddress)
        .storeAddress(toAddress)
        .storeInt(0, 2)             // custom_payload (empty)
        .storeCoins(22000000)       // forward amount
        .storeInt(0, 1)
        .storeRef(forwardPayload)
    .endCell();

    var message: builder = beginCell()
        .storeUint(0x18, 6)
        .storeAddress(toJettonWallet)
        .storeCoins(tonsAmont)
        .storeUint(1, 1 + 4 + 4 + 64 + 32 + 1 + 1)
        .storeRef(body);
    
    sendRawMessage(message.endCell(), sendMode);
}

@inline
fun transferNft(nftAddress: address, queryId: int, senderAddress: address) {
    var body: cell = beginCell()
        .storeUint(OP_NFT_TRANSFER, 32)      // Operation code for NFT transfer
        .storeUint(queryId, 64)              // Unique query identifier
        .storeAddress(senderAddress)         // New owner address
        .storeAddress(senderAddress)         // Response address
        .storeInt(0, 2)                       // Empty custom_payload (Maybe ^Cell)
        .storeCoins(22000000)                // Forward amount to new owner
        .storeInt(0, 1)                       // No forward_payload (Either Cell ^Cell)
    .endCell();

    var nftMsg: builder = beginCell()
        .storeUint(0x18, 6)                  // Message header
        .storeAddress(nftAddress)            // Destination NFT address
        .storeCoins(50000000)                // Amount of TON to send
        .storeUint(1, 1 + 4 + 4 + 64 + 32 + 1 + 1) // Default message headers
        .storeRef(body);                     // Reference to the body

    sendRawMessage(nftMsg.endCell(), 1);
}

@inline
fun burnNft(nftAddress: address, queryId: int) {
    var forwardPayload: cell = beginCell().endCell();

    var body: cell = beginCell()
        .storeUint(OP_NFT_TRANSFER, 32)
        .storeUint(queryId, 64)
        .storeAddress(BURN_ADDRESS)          // new_owner_address
        .storeAddress(BURN_ADDRESS)          // response_address
        .storeInt(0, 2)                      // empty custom_payload
        .storeCoins(22000000)                // forward amount to new_owner_address
        .storeInt(0, 1)
        .storeRef(forwardPayload)
    .endCell();

    var nftMsg: builder = beginCell()
        .storeUint(0x18, 6)                  // Message header
        .storeAddress(nftAddress)            // Destination NFT address
        .storeCoins(50000000)                // Amount of TON to send
        .storeUint(1, 1 + 4 + 4 + 64 + 32 + 1 + 1) // Default message headers
        .storeRef(body);                     // Reference to the body

    sendRawMessage(nftMsg.endCell(), 1);
}

@inline
fun transferNftComment(nftAddress: address, queryId: int, senderAddress: address, comment: slice) {
    var forwardPayload: cell = beginCell()
        .storeUint(0, 32)           // Indicates the presence of a comment
        .storeSlice(comment)       // Still a slice, since it's just text or custom data
    .endCell();

    var body: cell = beginCell()
        .storeUint(OP_NFT_TRANSFER, 32)
        .storeUint(queryId, 64)
        .storeAddress(senderAddress) // new_owner_address
        .storeAddress(senderAddress) // response_address
        .storeInt(0, 2)              // empty custom_payload
        .storeCoins(22000000)        // forward amount to new_owner_address
        .storeInt(0, 1)
        .storeRef(forwardPayload)
    .endCell();

    var nftMsg: builder = beginCell()
        .storeUint(0x18, 6)
        .storeAddress(nftAddress)
        .storeCoins(50000000)
        .storeUint(1, 1 + 4 + 4 + 64 + 32 + 1 + 1) // default message headers
        .storeRef(body);

    sendRawMessage(nftMsg.endCell(), 1);
}

@inline
fun burnNftComment(nftAddress: address, queryId: int, comment: slice) {
    var forwardPayload: cell = beginCell()
        .storeUint(0, 32)           // Indicates the presence of a comment
        .storeSlice(comment)       // Still a slice
    .endCell();

    var body: cell = beginCell()
        .storeUint(OP_NFT_TRANSFER, 32)
        .storeUint(queryId, 64)
        .storeAddress(BURN_ADDRESS) // new_owner_address
        .storeAddress(BURN_ADDRESS) // response_address
        .storeInt(0, 2)             // empty custom_payload
        .storeCoins(22000000)       // forward amount to new_owner_address
        .storeInt(0, 1)
        .storeRef(forwardPayload)
    .endCell();

    var nftMsg: builder = beginCell()
        .storeUint(0x18, 6)
        .storeAddress(nftAddress)
        .storeCoins(50000000)
        .storeUint(1, 1 + 4 + 4 + 64 + 32 + 1 + 1)
        .storeRef(body);

    sendRawMessage(nftMsg.endCell(), 1);
}

@inline
fun addComment(comment: slice): cell {
    return beginCell()
        .storeUint(0, 32)
        .storeSlice(comment)
    .endCell();
}

@inline 
fun returnFunds(senderAddress: address, msgValue: int) {
    var msg = beginCell()
        .storeUint(0x10, 6)
        .storeAddress(senderAddress) 
        .storeCoins(msgValue)
        .storeUint(0, 107)
    .endCell();
    sendRawMessage(msg, 0);
}

@inline
fun swapToJettonDeDust(
    toSend: int,
    poolAddress: address,
) {
    var msg = beginCell()
        .storeUint(0x18, 6)
        .storeAddress(TON_VAULT_ADDRESS_DEDUST)
        .storeCoins(toSend)
        .storeUint(0, 107)
        .storeUint(OP_DEDUST_SWAP_TO_JETTON, 32)
        .storeUint(0, 64)
        .storeCoins(toSend - toNano(125) / 1000)
        .storeAddress(poolAddress)
        .storeUint(0, 1)
        .storeCoins(0)
        .storeMaybeRef(null)
        .storeRef(
            beginCell()
                .storeUint(blockchain.now() + 60 * 3, 32)
                .storeAddress(myAddress())
                .storeAddress(myAddress())
                .storeMaybeRef(null)
                .storeMaybeRef(null)
            .endCell()
        )
    .endCell();
    sendRawMessage(msg, 1);
}

@inline
fun swapToTonDeDust(
    myJettonWallet: address,
    jettonVaultAddress: address,
    toSwap: int,
    poolAddress: address,
) {
    var msg = beginCell()
        .storeUint(0x18, 6)
        .storeAddress(myJettonWallet)
        .storeCoins(toNano(175) / 1000)
        .storeUint(0, 107)
        .storeUint(OP_JETTON_TRANSFER, 32)
        .storeUint(blockchain.logicalTime(), 64)
        .storeCoins(toSwap)
        .storeAddress(jettonVaultAddress)   
        .storeUint(0, 2) 
        .storeInt(0, 1)  
        .storeCoins(toNano(125) / 1000)   
        .storeMaybeRef(
            beginCell()
                .storeUint(OP_DEDUST_SWAP_TO_TON, 32)
                .storeAddress(poolAddress)
                .storeUint(0, 1)
                .storeCoins(0)
                .storeMaybeRef(null)
                .storeRef(
                    beginCell()
                        .storeUint(0, 32)
                        .storeAddress(myAddress())
                        .storeAddress(myAddress())
                        .storeMaybeRef(null)
                        .storeMaybeRef(null)
                    .endCell() 
                )
            .endCell()
        ) 
    .endCell();
    sendRawMessage(msg, 1);
}

/* NEW MESSAGES */

/* JETTON */

type ForwardPayloadRemainder = RemainingBitsAndRefs

struct (0x0f8a7ea5) AskToTransfer {
    queryId: uint64
    jettonAmount: coins
    transferRecipient: address
    sendExcessesTo: address
    customPayload: cell?
    forwardTonAmount: coins
    forwardPayload: ForwardPayloadRemainder // or cell? [forwardPayload: createEmptyCell()]
}

struct (0x7362d09c) TransferNotificationForRecipient {
    queryId: uint64
    jettonAmount: coins
    transferInitiator: address
    forwardPayload: ForwardPayloadRemainder // .fromSlice(...)
    // forwardPayload: cell // .fromCell(...)
}

struct (0x178d4519) InternalTransferStep {
    queryId: uint64
    jettonAmount: coins
    transferInitiator: address
    sendExcessesTo: address
    forwardTonAmount: coins
    forwardPayload: ForwardPayloadRemainder
}

struct (0xd53276db) ReturnExcessesBack {
    queryId: uint64
}

struct (0x595f07bc) AskToBurn {
    queryId: uint64
    jettonAmount: coins
    sendExcessesTo: address
    customPayload: cell?
}

struct (0x7bdd97de) BurnNotificationForMinter {
    queryId: uint64
    jettonAmount: coins
    burnInitiator: address
    sendExcessesTo: address
}

struct (0x2c76b973) RequestWalletAddress {
    queryId: uint64
    ownerAddress: address
    includeOwnerAddress: bool
}

struct (0xd1735400) ResponseWalletAddress {
    queryId: uint64
    jettonWalletAddress: address
    ownerAddress: Cell<address>?
}

struct (0x00000015) MintNewJettons {
    queryId: uint64
    mintRecipient: address
    tonAmount: coins
    internalTransferMsg: Cell<InternalTransferStep>
}

struct (0x00000003) ChangeMinterAdmin {
    queryId: uint64
    newAdminAddress: address
}

struct (0x00000004) ChangeMinterContent {
    queryId: uint64
    newContent: cell
}

// example

/*
    var reply = createMessage({
        bounce: true,
        value: ton("0.055"),
        dest: contractJettonWallet,
        body: JettonTransfer {
            queryId: 0,
            amount: ton("10"),
            destination: data.ownerAddress,
            responseDestination: createAddressNone(),
            forwardTonAmount: ton("0.02"),
            forwardPayload: addComment("test")
        }
        
    });
    reply.send(SEND_MODE_REGULAR);
*/

// /* NFT */

// import "storage"

// struct NftItemInitAtDeployment {
//     ownerAddress: address
//     content: Cell<SnakeString>
// }

// struct (0x693d3950) RequestRoyaltyParams {
//     queryId: uint64
// }

// struct (0xa8cb00ad) ResponseRoyaltyParams {
//     queryId: uint64
//     royaltyParams: RoyaltyParams
// }

// struct (0x00000001) DeployNft {
//     queryId: uint64
//     itemIndex: uint64
//     attachTonAmount: coins
//     initParams: Cell<NftItemInitAtDeployment>
// }

// struct (0x00000002) BatchDeployNfts {
//     queryId: uint64
//     deployList: dict        // actually, a map of [itemIndex => BatchDeployDictItem]
// }

// struct BatchDeployDictItem {
//     attachTonAmount: coins
//     initParams: Cell<NftItemInitAtDeployment>
// }

// struct (0x00000003) ChangeCollectionAdmin {
//     queryId: uint64
//     newAdminAddress: address
// }

// struct (0x2fcb26a2) RequestStaticData {
//     queryId: uint64
// }

// struct (0x8b771735) ResponseStaticData {
//     queryId: uint64
//     itemIndex: uint256
//     collectionAddress: address
// }

// struct (0x05138d91) NotificationForNewOwner {
//     queryId: uint64
//     oldOwnerAddress: address
//     payload: RemainingBitsAndRefs
// }

// struct (0xd53276db) ReturnExcessesBack {
//     queryId: uint64
// }

// struct (0x5fcc3d14) AskToChangeOwnership {
//     queryId: uint64
//     newOwnerAddress: address
//     sendExcessesTo: address
//     customPayload: dict
//     forwardTonAmount: coins
//     forwardPayload: RemainingBitsAndRefs
// }

/* DEDUST */

struct SwapStep {
    poolAddress: address,
    kind: uint1 = 0, // can only be 0 as of now
    limit: coins = 0,
    nextStep: cell? = null 
}

struct SwapParams {
    deadline: uint32 = 0, // default 0
    recipientAddress: address? = null,
    referralAddress: address? = null,
    fulfillPayload: cell? = null,
    rejectPayload: cell? = null 
}

struct (0xea06185d) DeDustNativeSwap {
    queryId: uint64 = 0,
    amount: coins, // toncoin amount for the swap
    poolAddress: address,
    kind: uint1 = 0,
    limit: coins = 0,
    nextStep: Cell<SwapStep>? = null,
    swapParams: Cell<SwapParams>
}

struct (0xe3a0d482) DeDustJettonSwap { // use in jetton transfer
    poolAddress: address,
    kind: uint1 = 0,
    limit: coins = 0,
    nextStep: Cell<SwapStep>? = null,
    swapParams: Cell<SwapParams>
}

/*
    var reply = createMessage({
        bounce: true,
        value: ton("0.055"),
        dest: contractJettonWallet,
        body: JettonTransfer {
            queryId: 0,
            amount: ton("10"),
            destination: data.ownerAddress,
            responseDestination: createAddressNone(),
            forwardTonAmount: ton("0.02"),
            forwardPayload: DeDustJettonSwap {
                poolAddress: address("EQ...UQ") // address of the swap pool, for example TON/DUST
                ...
            }
        }
    });
    reply.send(SEND_MODE_REGULAR);
*/

