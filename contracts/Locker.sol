pragma solidity 0.8.13;

import "OpenZeppelin/openzeppelin-contracts@4.5.0/contracts/token/ERC721/ERC721.sol";
import "OpenZeppelin/openzeppelin-contracts@4.5.0/contracts/token/ERC721/IERC721.sol";

struct Lock {
  IERC721 nft;
  uint256 tokenId;
  bytes32 secret;
}

contract Locker is ERC721("Locker", "LOCK") {
  Lock[] public locks;

  function join(
    IERC721 _nft,
    uint256 _tokenId,
    bytes32 _secret
  ) external {
    _nft.safeTransferFrom(msg.sender, address(this), _tokenId);
    uint256 id = locks.length;
    locks.push(Lock({ nft: _nft, tokenId: _tokenId, secret: _secret }));
    _safeMint(msg.sender, id);
  }

  function exit(uint256 _id, string memory _seed) external {
    require(ownerOf(_id) == msg.sender, "!owner");
    _burn(_id);
    Lock memory lock = locks[_id];
    require(keccak256(abi.encodePacked(lock.nft, lock.tokenId, _seed)) == lock.secret, "!seed");
    lock.nft.safeTransferFrom(address(this), msg.sender, lock.tokenId);
  }
}
