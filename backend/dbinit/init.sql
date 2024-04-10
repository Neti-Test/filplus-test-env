create table if not exists allocation_amounts (
    id serial not null,
    allocator_id bigint not null,
    quantity_option text not null
);

create table if not exists allocators (
    id serial not null,
    owner text not null,
    repo text not null,
    installation_id bigint,
    multisig_address text,
    verifiers_gh_handles text,
    multisig_threshold integer,
    allocation_amount_type text
);

alter table allocators
    add column address text,
    add column tooling text;