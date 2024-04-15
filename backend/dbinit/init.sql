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

create table if not exists applications (
    id text not null,
    owner text not null,
    repo text not null,
    pr_number bigint not null,
    application text,
    updated_at timestamp with time zone not null default current_timestamp,
    sha text,
    path text,
    primary key (id, owner, repo, pr_number)
);
