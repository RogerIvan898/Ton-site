import "updlib.tolk";

struct Storage {
  owner: address,
  counter: uint64
}

@inline
fun loadData() {
  var cs = contract.getData().beginParse();
    
  return {
    owner: cs.loadAddress(),
    counter: cs.loadUint(64),
  } as Storage
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
	if (msgBody.isEndOfBits()) {
		return;
	}

	var cs: slice = msgFull.beginParse();
	var flags = cs.loadMessageFlags();

	if ((flags & 1) != 0) {
		return;
	}

	var data = loadData();

	var senderAddress = cs.loadAddress();
	var op = msgBody.loadUint(32);

	if (op == 0) {
		if (msgBody.bitsEqual("increment")) {
			data.counter +=1;

			var reply = createMessage({
				bounce: false,
				value: ton("0.0001"),
				dest: data.owner,
				body: addComment("Add"),
			});

			reply.send(SEND_MODE_REGULAR);
			saveData(data);

			return;
		}

		return;
	}

	throw 0xfffff;
}

get fun get_owner() {
	var data = loadData();
	return data.owner;
}

get fun get_counter() {
	var data = loadData();
	return data.counter;
}
