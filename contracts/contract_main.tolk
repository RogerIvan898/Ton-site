import "updlib.tolk";
import "constants";
import "structs";
import "utils";

@inline
fun loadData() {
  var cs = contract.getData().beginParse();
    
  return Storage {
    owner: cs.loadAddress(),
    counter: cs.loadUint(64),
  }
}

@inline
fun saveData(data: Storage) {
  contract.setData(
    beginCell()
      .storeAddress(data.owner)
      .storeUint(data.counter, 64)
	  .endCell()
  );
}

fun onInternalMessage(myBalance: int, msgValue: int, msgFull: cell, msgBody: slice) {
	if (msgBody.isEndOfBits()) return;

	var cs: slice = msgFull.beginParse();
	var flags = cs.loadMessageFlags();

	if (isDebounce(flags)) return;

	var data = loadData();

	var senderAddress = cs.loadAddress();
	var op = msgBody.loadUint(32);

	if (op == 0) {
		if (msgBody.bitsEqual("increment")) {

			incrementStorage(data, senderAddress);

			var reply =   createMessage({
				bounce: false,
				value: ton("0.0001"),
				dest: data.owner,
				body: addComment("Counter incremented"),
			});
			reply.send(SEND_MODE_REGULAR);

			saveData(data);

			return;
		}

		return;
	}

	throw ERR_UNKNOWN_OPERATION;
}

get fun get_owner() {
	return loadData().owner;
}

get fun get_counter() {
	return loadData().counter;
}
